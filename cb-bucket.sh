#!/usr/bin/env bash

echo "Running cb-bucket.sh"

adminUsername=$1
adminPassword=$2
#stackName=$3
stackName=${3}-kernel

echo "Using the settings:"
echo adminUsername \'$adminUsername\'
echo adminPassword \'$adminPassword\'

echo ${stackName}
if echo ${stackName} | grep -q kernel ; then
  echo "Kernel Stack"
  buckets=${buckets:-"common dcms gradebook ims lec led lpb"}
elif echo ${stackName} | grep -q eses ; then
  echo "eses Stack"
  buckets=${buckets:-"autobahncon autobahnpro dataingestion iam"}
elif echo ${stackName} | grep -q analytics ; then
  echo "analytics Stack"
  buckets=${buckets:-"ams sps pls leamose tot rms"}
else
  echo "No matching stack name"
fi

  cd /opt/couchbase/bin/


  for bucket in ${buckets} ; do
    resp_code=$(curl -s -w "%{http_code}" -u ${adminUsername}:${adminPassword} http://127.0.0.1:8091/pools/default/buckets/${bucket} -o /dev/null)
    if [ "${resp_code}" == "404" ]; then
      echo "Configuring bucket ${bucket}..."
       /opt/couchbase/bin/couchbase-cli bucket-create \
      --cluster 127.0.0.1:8091 \
      --bucket="${bucket}" \
      --bucket-type=couchbase \
      --bucket-ramsize=512 \
      --bucket-replica=1 \
      --wait \
      --username ${adminUsername} \
      --password ${adminPassword};
      if [ "$?" == "0" ]; then
        echo "Created bucket ${bucket}"
      else
        echo "Some issue with Creating bucket ${bucket}"
      fi
    fi
      # Create primary index
      echo "Creating index for ${bucket}"
      /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE PRIMARY INDEX ${bucket} ON ${bucket}";
      if [ "$?" == "0" ]; then
        echo "Created index for ${bucket}"
      else
        echo "Some issue with Creating index for ${bucket}"
      fi
  done

  if echo ${stackName} | grep -q kernel ; then
    echo "Indexes in Kernel Stack"
   # Create primary index
   echo "Adding index for dcms bucket"
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX dcmsDocTypeContent ON dcms(docType) WHERE (docType = 'content')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX linksAndCategory ON dcms(links,category)";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX docId ON dcms(id)";

   echo "Adding index for lec bucket"
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX lecArrayIndex ON lec((distinct (array (v.id) for v in actors end))) WHERE (docType = 'learningassets')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX lecDocTypeLearningAssets ON lec(docType) WHERE (docType = 'learningassets')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX lecGetCourse ON lec(assetType) WHERE (assetType = 'COURSE')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX lecIndexM0 ON lec(context.LAId) WHERE (context.LAId = 'Squires-M0')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX lecId ON lec(id)";

   echo "Adding index for led bucket"
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX learnercoursestateIndex ON led(docType) WHERE (docType = 'learnercoursestate')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledCourseId ON led(preAssessmentStatus,(context.courseId))";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledIndex500 ON led(context.learnerId) WHERE (context.learnerId = '500')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledSubsCources ON led(docType,assetType,(context.learnerId),(scope.\`group\`)) \
   WHERE (((docType = 'learningassets') and (assetType = 'SUBSCRIBED_COURSE')) and ((scope.\`group\`) = 'SUBSCRIBED_COURSE'))";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX subscribeCourseIndex ON led(assetType) WHERE (assetType = 'SUBSCRIBED_COURSE')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledSectionId ON led(sectionId,docType)";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX learnercourseoutcomesArchiveIndex ON led(docType) WHERE (docType = 'learnercourseoutcomesArchive')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX instructorcoursesubscriptionIndex ON led(docType) WHERE (docType = 'instructorcoursesubscription')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledId ON led(id)";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX laddiagnosticid ON led((context.LAId),(context.LAType),(scope.\`group\`)) \
   WHERE (((context.LAType) = 'COURSE') and ((scope.\`group\`) = 'DIAGNOSTIC'))";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX learnercourseoutcomesIndex ON led(docType) WHERE (docType = 'learnercourseoutcomes')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledLearnerDetails ON led(docType,courseId,(instructors.instructorId)) WHERE (docType = 'learnercourseoutcomes')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledSectionIdUserId ON led(sectionId,userId,docType)";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX LearnerAnalyticsSessionIndex ON led(docType) WHERE (docType = 'LearnerAnalyticsSession')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX learnercourseIndex ON led(docType) WHERE (docType = 'learnercourse')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledDetails ON led(docType,courseId) WHERE (docType = 'learnercourseoutcomes')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledassetTypeLearnerId ON led(assetType,learnerId)";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ledSubsCources_blankAssetType ON led(docType,assetType,(context.learnerId),(scope.\`group\`)) \
    WHERE (((docType = 'learningassets') and (assetType = '')) and ((scope.\`group\`) = 'SUBSCRIBED_COURSE'))";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX learnercourseglp1517231821348 ON led(docType,courseId) WHERE (docType = 'learnercourse')";
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX uniqueIdentifierIndex ON led(uniqueIdentifier)";

   echo "Adding index for lpb bucket"
   /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX lpbDocTypeLearningAssets ON lpb(docType) WHERE (docType = 'learningassets')";
fi


if echo ${stackName} | grep -q eses ; then
  echo "Indexes in eses Stack"
 /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX iamidglpUserId ON iam(id,glpUserId)";

fi

if echo ${stackName} | grep -q analytics ; then
  echo "Indexes of analytics Stack"

  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ams_id ON ams(id)";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ams_diagnostic ON ams(scope.category,scope.COURSE_OBJ_ID,_id,(scope.CHAPTER_OBJ_ID), \
  (scope.CHAPTER_OBJ),(properties.DIAGNOSTIC))";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ams_practice ON ams(scope.category,scope.OBJECTIVE_OBJ_ID,scope.COURSE_OBJ_ID,_id, \
  scope.\`GROUP\`,scope.policy,properties.PRACTICE)";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ams_scope_session_id ON ams((scope.SESSION_ID))";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ams_post_assessment ON ams(properties.isLastEO,scope.CHAPTER_OBJ_ID)";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX ams_email_stats ON ams(_id,scope.COURSE_OBJ_ID)";

  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX leamose_user ON leamose(((scope.TAGS).sessionId),(scope.ASSET_ID))";

  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX sps_genric ON sps(scope.COURSE_ID,dependencies.enablingObjectives[0].objId)";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX sps_events_publish ON sps(docType,(scope.COURSE_ID))";
  /opt/couchbase/bin/cbq -u ${adminUsername} -p ${adminPassword} --script="CREATE INDEX sps_id ON sps(id)";

fi
