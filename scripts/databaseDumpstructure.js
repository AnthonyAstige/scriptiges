#!/usr/bin/env node
/* eslint-disable no-console */
import { exec } from "child_process";
import { config } from "dotenv";
import process from "process";

config();

const container = process.env.DOCKER_CONTAINER_POSTGRES_NAME;
const username = process.env.POSTGRES_USER;
const database = process.env.POSTGRES_DB;
const outputFile = `./prisma/${database}-schema.sql`;

if (!username || !database) {
  throw new Error("Environment variables POSTGRES_USER or POSTGRES_DB are not set.");
}

const command = `docker exec ${container} pg_dump --username=${username} -s ${database} > ${outputFile}`;

await new Promise((resolve, reject) => {
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return;
    }

    if (stderr) {
      console.error(`Stderr: ${stderr}`);
      return;
    }

    if (error) {
      console.error(`Error: ${error.message}`);
      reject(error);
      return;
    }

    if (stderr) {
      console.error(`Stderr: ${stderr}`);
      reject(new Error(stderr));
      return;
    }

    if (stdout.trim() === "") {
      console.log(`Updated ${outputFile}`);
    } else {
      process.stdout.write(stdout);
    }

    resolve();
  });
});
