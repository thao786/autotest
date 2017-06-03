Issues to be fixed:
- make element selector SMARTER
- double forms in click select are confusing. even I got messed up

create new model:
- belongs to a test, an assertion
- has a step (nullable) in which it failed
- runID: something generated from ruby, pass as a parameter to eclipse
- fields:
    error
- maybe include a picture after each step 
    (no video is ok for beta)

methods in model:
    video path (gotta be secure S3 path so others can't look up)
    screenshot of how it failed (secure S3 path)


run test from API





