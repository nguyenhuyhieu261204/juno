import { Request, Response, Router } from "express";
import mongoose from "mongoose";
import { HTTPSTATUS } from "../config/http.config";
import { asyncHandler } from "../middlewares/asyncHandler.middleware";

const healthRouter = Router();

/**
 * GET /health
 * Health check endpoint that returns server status and database connectivity
 */
healthRouter.get(
  "/",
  asyncHandler(async (req: Request, res: Response) => {
    const startTime = Date.now();

    const health = {
      status: "UP",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: {
        status: "UNKNOWN",
        responseTime: 0,
      },
      responseTime: 0,
    };

    try {
      // Check database connection
      const dbStartTime = Date.now();

      if (
        mongoose.connection.readyState === 1 ||
        mongoose.connection.readyState === 2
      ) {
        // 1 = connected, 2 = connecting
        await mongoose.connection.db?.admin().ping();
        health.database.status = "UP";
        health.database.responseTime = Date.now() - dbStartTime;
      } else {
        health.database.status = "DOWN";
        health.status = "DEGRADED";
      }
    } catch (error) {
      health.database.status = "DOWN";
      health.status = "DEGRADED";
    }

    health.responseTime = Date.now() - startTime;

    const statusCode =
      health.status === "UP" ? HTTPSTATUS.OK : HTTPSTATUS.SERVICE_UNAVAILABLE;

    return res.status(statusCode).json(health);
  })
);

/**
 * GET /health/ready
 * Readiness probe - checks if the service is ready to accept requests
 */
healthRouter.get(
  "/ready",
  asyncHandler(async (req: Request, res: Response) => {
    const isReady =
      mongoose.connection.readyState === 1 && process.uptime() > 5; // Give 5 seconds for startup

    if (isReady) {
      return res.status(HTTPSTATUS.OK).json({
        ready: true,
        message: "Service is ready to accept requests",
      });
    } else {
      return res.status(HTTPSTATUS.SERVICE_UNAVAILABLE).json({
        ready: false,
        message: "Service is not ready yet",
      });
    }
  })
);

/**
 * GET /health/live
 * Liveness probe - checks if the service is alive
 */
healthRouter.get(
  "/live",
  asyncHandler(async (req: Request, res: Response) => {
    return res.status(HTTPSTATUS.OK).json({
      alive: true,
      timestamp: new Date().toISOString(),
    });
  })
);

export default healthRouter;
