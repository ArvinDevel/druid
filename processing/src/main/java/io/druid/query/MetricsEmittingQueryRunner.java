/*
 * Licensed to Metamarkets Group Inc. (Metamarkets) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. Metamarkets licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.druid.query;

import com.google.common.base.Function;
import com.google.common.base.Strings;
import com.google.common.collect.Maps;
import com.metamx.common.guava.Accumulator;
import com.metamx.common.guava.Sequence;
import com.metamx.common.guava.Yielder;
import com.metamx.common.guava.YieldingAccumulator;
import com.metamx.emitter.service.ServiceEmitter;
import com.metamx.emitter.service.ServiceMetricEvent;

import java.io.IOException;
import java.util.Map;
import io.druid.segment.ReferenceCountingSegment;
import com.metamx.common.logger.Logger;

/**
 */
public class MetricsEmittingQueryRunner<T> implements QueryRunner<T>
{
  private static final Logger log = new Logger(MetricsEmittingQueryRunner.class);

  private static final String DEFAULT_METRIC_NAME = "query/partial/time";

  private final ServiceEmitter emitter;
  private final Function<Query<T>, ServiceMetricEvent.Builder> builderFn;
  private final QueryRunner<T> queryRunner;
  private final long creationTime;
  private final String metricName;
  private final Map<String, String> userDimensions;
  private final ReferenceCountingSegment adapter;

  public MetricsEmittingQueryRunner(
      ServiceEmitter emitter,
      Function<Query<T>, ServiceMetricEvent.Builder> builderFn,
      QueryRunner<T> queryRunner
  )
  {
    this(emitter, builderFn, queryRunner, DEFAULT_METRIC_NAME, Maps.<String, String>newHashMap(), null);
  }

  public MetricsEmittingQueryRunner(
      ServiceEmitter emitter,
      Function<Query<T>, ServiceMetricEvent.Builder> builderFn,
      QueryRunner<T> queryRunner,
      long creationTime,
      String metricName,
      Map<String, String> userDimensions,
      ReferenceCountingSegment adapter
  )
  {
    this.emitter = emitter;
    this.builderFn = builderFn;
    this.queryRunner = queryRunner;
    this.creationTime = creationTime;
    this.metricName = metricName;
    this.userDimensions = userDimensions;
    this.adapter = adapter;
  }

  public MetricsEmittingQueryRunner(
      ServiceEmitter emitter,
      Function<Query<T>, ServiceMetricEvent.Builder> builderFn,
      QueryRunner<T> queryRunner,
      String metricName,
      Map<String, String> userDimensions,
      ReferenceCountingSegment adapter
  )
  {
    this(emitter, builderFn, queryRunner, -1, metricName, userDimensions, adapter);
  }


  public MetricsEmittingQueryRunner<T> withWaitMeasuredFromNow()
  {
    return new MetricsEmittingQueryRunner<T>(
        emitter,
        builderFn,
        queryRunner,
        System.currentTimeMillis(),
        metricName,
        userDimensions,
        adapter
    );
  }

  @Override
  public Sequence<T> run(final Query<T> query, final Map<String, Object> responseContext)
  {
    final ServiceMetricEvent.Builder builder = builderFn.apply(query);

    for (Map.Entry<String, String> userDimension : userDimensions.entrySet()) {
      builder.setDimension(userDimension.getKey(), userDimension.getValue());
    }

    builder.setDimension(DruidMetrics.ID, Strings.nullToEmpty(query.getId()));

    return new Sequence<T>()
    {
      @Override
      public <OutType> OutType accumulate(OutType outType, Accumulator<OutType, T> accumulator)
      {
        OutType retVal;

        long startTime = System.currentTimeMillis();
        try {
          retVal = queryRunner.run(query, responseContext).accumulate(outType, accumulator);
        }
        catch (RuntimeException e) {
          builder.setDimension(DruidMetrics.STATUS, "failed");
          throw e;
        }
        catch (Error e) {
          builder.setDimension(DruidMetrics.STATUS, "failed");
          throw e;
        }
        finally {
          long timeTaken = System.currentTimeMillis() - startTime;
          if(metricName == "query/segment/time"){
            query.updateSegmentQueryTime(timeTaken);
            log.info("Updated segment queryID %s, querySegment %s, queryIntervals %s, query time %d, hashcode %d", query.getId(), query.getDuration().toString(), query.getIntervals().toString(), timeTaken, query.hashCode());
          }

          emitter.emit(builder.build(metricName, timeTaken));
          if (metricName == "query/segment/time" && adapter != null)
            adapter.updateSegmentQueryTime(timeTaken);

          if (creationTime > 0) {
            emitter.emit(builder.build("query/wait/time", startTime - creationTime));
          }
        }

        return retVal;
      }

      @Override
      public <OutType> Yielder<OutType> toYielder(OutType initValue, YieldingAccumulator<OutType, T> accumulator)
      {
        Yielder<OutType> retVal;

        long startTime = System.currentTimeMillis();
        try {
          retVal = queryRunner.run(query, responseContext).toYielder(initValue, accumulator);
        }
        catch (RuntimeException e) {
          builder.setDimension(DruidMetrics.STATUS, "failed");
          throw e;
        }
        catch (Error e) {
          builder.setDimension(DruidMetrics.STATUS, "failed");
          throw e;
        }

        return makeYielder(startTime, retVal, builder);
      }

      private <OutType> Yielder<OutType> makeYielder(
          final long startTime,
          final Yielder<OutType> yielder,
          final ServiceMetricEvent.Builder builder
      )
      {
        return new Yielder<OutType>()
        {
          @Override
          public OutType get()
          {
            return yielder.get();
          }

          @Override
          public Yielder<OutType> next(OutType initValue)
          {
            try {
              return makeYielder(startTime, yielder.next(initValue), builder);
            }
            catch (RuntimeException e) {
              builder.setDimension(DruidMetrics.STATUS, "failed");
              throw e;
            }
            catch (Error e) {
              builder.setDimension(DruidMetrics.STATUS, "failed");
              throw e;
            }
          }

          @Override
          public boolean isDone()
          {
            return yielder.isDone();
          }

          @Override
          public void close() throws IOException
          {
            try {
              if (!isDone() && builder.getDimension(DruidMetrics.STATUS) == null) {
                builder.setDimension(DruidMetrics.STATUS, "short");
              }

              long timeTaken = System.currentTimeMillis() - startTime;
              if(metricName == "query/segment/time"){
                query.updateSegmentQueryTime(timeTaken);
                log.info("Updated segment queryID %s, querySegment %s, queryIntervals %s, query time %d, hashcode %d", query.getId(), query.getDuration().toString(), query.getIntervals().toString(), timeTaken, query.hashCode());
              }
              
              emitter.emit(builder.build(metricName, timeTaken));
              if (metricName == "query/segment/time" && adapter != null)
                adapter.updateSegmentQueryTime(timeTaken);
              if (creationTime > 0) {
                emitter.emit(builder.build("query/wait/time", startTime - creationTime));
              }
            }
            finally {
              yielder.close();
            }
          }
        };
      }
    };
  }
}
