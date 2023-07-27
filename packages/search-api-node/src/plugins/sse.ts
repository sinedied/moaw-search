import fp from 'fastify-plugin'
import { FastifySSEPlugin } from "fastify-sse-v2";

/**
 * This plugins adds some utilities to handle http errors
 *
 * @see https://github.com/fastify/fastify-sensible
 */
export default fp(async (fastify) => {
  fastify.register(FastifySSEPlugin)
});
