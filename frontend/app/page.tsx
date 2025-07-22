"use client";
import {
  CheckCircle,
  XCircle,
  Loader2,
  Activity,
  Database,
  Zap,
  Server,
} from "lucide-react";
import { useEffect, useState } from "react";
interface ServiceStatus {
  status: string;
  message: string;
  postgresql_version?: string;
  redis_version?: string;
  connected_clients?: number;
}

interface HealthData {
  status: string;
  services: {
    postgresql: ServiceStatus;
    redis: ServiceStatus;
    api: ServiceStatus;
  };
}

export default function Home() {
  const [healthData, setHealthData] = useState<HealthData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const checkHealth = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${
          process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000"
        }/api/v1/health`,
        { method: "GET" }
      );

      const data: HealthData = await response.json();
      setHealthData(data);
    } catch (err) {
      console.error("Health check failed:", err);
      setError(err instanceof Error ? err.message : "Unknown error occurred");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    checkHealth();
    const interval = setInterval(checkHealth, 10000); // Check every 10 seconds
    return () => clearInterval(interval);
  }, []);

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "connected":
      case "running":
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case "error":
        return <XCircle className="w-5 h-5 text-red-500" />;
      default:
        return <Loader2 className="w-5 h-5 text-yellow-500 animate-spin" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "connected":
      case "running":
        return "border-green-500 bg-green-50 dark:bg-green-900/20";
      case "error":
        return "border-red-500 bg-red-50 dark:bg-red-900/20";
      default:
        return "border-yellow-500 bg-yellow-50 dark:bg-yellow-900/20";
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-6xl font-bold text-white mb-4">
          FnF Trading System
        </h1>
        <p className="text-xl text-gray-300 mb-8">
          Full-Stack Trading Platform with FastAPI & Next.js
        </p>

        <button
          onClick={checkHealth}
          disabled={loading}
          className="inline-flex items-center px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white font-medium rounded-lg transition-colors"
        >
          {loading ? (
            <Loader2 className="w-4 h-4 mr-2 animate-spin" />
          ) : (
            <Activity className="w-4 h-4 mr-2" />
          )}
          {loading ? "Checking..." : "Refresh Health Check"}
        </button>
      </div>

      {error && (
        <div className="max-w-2xl mx-auto mb-8 p-4 bg-red-900/20 border border-red-500 rounded-lg">
          <div className="flex items-center">
            <XCircle className="w-5 h-5 text-red-500 mr-3" />
            <div>
              <p className="text-red-400 font-medium">Connection Error</p>
              <p className="text-red-300 text-sm">{error}</p>
            </div>
          </div>
        </div>
      )}

      <div className="max-w-4xl mx-auto">
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* API Service */}
          <div
            className={`p-6 rounded-lg border-2 transition-colors ${
              healthData?.services?.api
                ? getStatusColor(healthData.services.api.status)
                : "border-gray-500 bg-gray-50 dark:bg-gray-900/20"
            }`}
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <Server className="w-6 h-6 mr-3 text-blue-500" />
                <h3 className="text-lg font-semibold text-white">FastAPI</h3>
              </div>
              {healthData?.services?.api ? (
                getStatusIcon(healthData.services.api.status)
              ) : (
                <Loader2 className="w-5 h-5 text-gray-500 animate-spin" />
              )}
            </div>
            <p className="text-sm text-gray-300">
              {healthData?.services?.api?.message || "Checking API status..."}
            </p>
          </div>

          {/* PostgreSQL Service */}
          <div
            className={`p-6 rounded-lg border-2 transition-colors ${
              healthData?.services?.postgresql
                ? getStatusColor(healthData.services.postgresql.status)
                : "border-gray-500 bg-gray-50 dark:bg-gray-900/20"
            }`}
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <Database className="w-6 h-6 mr-3 text-blue-500" />
                <h3 className="text-lg font-semibold text-white">PostgreSQL</h3>
              </div>
              {healthData?.services?.postgresql ? (
                getStatusIcon(healthData.services.postgresql.status)
              ) : (
                <Loader2 className="w-5 h-5 text-gray-500 animate-spin" />
              )}
            </div>
            <p className="text-sm text-gray-300 mb-2">
              {healthData?.services?.postgresql?.message ||
                "Checking database status..."}
            </p>
            {healthData?.services?.postgresql?.postgresql_version && (
              <p className="text-xs text-gray-400">
                Version: {healthData.services.postgresql.postgresql_version}
              </p>
            )}
          </div>

          {/* Redis Service */}
          <div
            className={`p-6 rounded-lg border-2 transition-colors ${
              healthData?.services?.redis
                ? getStatusColor(healthData.services.redis.status)
                : "border-gray-500 bg-gray-50 dark:bg-gray-900/20"
            }`}
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <Zap className="w-6 h-6 mr-3 text-red-500" />
                <h3 className="text-lg font-semibold text-white">Redis</h3>
              </div>
              {healthData?.services?.redis ? (
                getStatusIcon(healthData.services.redis.status)
              ) : (
                <Loader2 className="w-5 h-5 text-gray-500 animate-spin" />
              )}
            </div>
            <p className="text-sm text-gray-300 mb-2">
              {healthData?.services?.redis?.message ||
                "Checking cache status..."}
            </p>
            {healthData?.services?.redis?.redis_version && (
              <p className="text-xs text-gray-400">
                Version: {healthData.services.redis.redis_version}
              </p>
            )}
          </div>
        </div>

        {/* Overall Status */}
        {healthData && (
          <div className="mt-8 p-6 bg-gray-800/50 rounded-lg border border-gray-600">
            <div className="flex items-center justify-center">
              <div
                className={`inline-flex items-center px-4 py-2 rounded-full ${
                  healthData.status === "healthy"
                    ? "bg-green-500/20 text-green-400 border border-green-500/30"
                    : "bg-red-500/20 text-red-400 border border-red-500/30"
                }`}
              >
                {healthData.status === "healthy" ? (
                  <CheckCircle className="w-4 h-4 mr-2" />
                ) : (
                  <XCircle className="w-4 h-4 mr-2" />
                )}
                System Status:{" "}
                {healthData.status.charAt(0).toUpperCase() +
                  healthData.status.slice(1)}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="text-center mt-12">
        <p className="text-gray-400 text-sm">
          Built with FastAPI, Next.js, PostgreSQL, Redis, and Docker
        </p>
      </div>
    </div>
  );
}
