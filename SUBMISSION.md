# Submission

Fork URL: <!-- paste the URL of your fork here -->

## Files to commit

- [ ] `notes.md`: your diagnosis, one line per container, committed to the repo

## Questions

Answer in your own words. Where a question asks for output, paste it in a code block.

### Q1. Paste `docker ps -a` as you first saw it. For each of the five `fa-` containers that was not healthy: its state, and the root cause in one sentence.

**Your answer:**

<!-- replace this line with your answer -->

### Q2. `fa-crashloop` kept restarting. Paste its `RestartCount` at two moments and the log line that explains it. Why does `--restart` make this kind of failure harder to notice?

**Your answer:**

<!-- replace this line with your answer -->

### Q3. Starting `fa-web` failed. Paste the exact error and the command that showed you who was holding port 8080. Why can two containers not publish the same host port?

**Your answer:**

<!-- replace this line with your answer -->

### Q4. Paste the `docker stats` line that identified the noisy container and the flags you used on the replacement worker (memory, CPU, log rotation, restart policy). What would have happened to the disk if nobody noticed for a month?

**Your answer:**

<!-- replace this line with your answer -->

### Q5. About `fa-mystery`, using only `docker inspect`, `docker exec` and `docker port`: which image and version, which user runs the main process, which port it listens on inside the container and which on your host, and what is the value of its `RELEASE` environment variable? Paste the commands you used.

**Your answer:**

<!-- replace this line with your answer -->

### Q6. What is the difference between `docker stop` and `docker kill`, and between `docker rm` and `docker rm -f`? When would you pick the harsher one?

**Your answer:**

<!-- replace this line with your answer -->

### Q7. Paste the output of `./verify.sh`. It must end with **ALL CHECKS PASSED**.

**Your answer:**

<!-- replace this line with your answer -->

### Q8. **Tear down.** Paste the output of `./verify-teardown.sh`. It must end with **TEARDOWN VERIFIED**.

**Your answer:**

<!-- replace this line with your answer -->
