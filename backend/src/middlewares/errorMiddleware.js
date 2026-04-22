import { ApiError } from "../utils/ApiError.js";

export function notFound(req, res) {
  res.status(404).json({ message: `Route not found: ${req.originalUrl}` });
}

export function errorHandler(err, req, res, next) {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      message: err.message,
      details: err.details
    });
  }

  console.error(err);

  return res.status(500).json({
    message: "Internal server error"
  });
}
