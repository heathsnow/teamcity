#!/usr/bin/env bash
set -e

echo "Determining Linux distribution..."
if [ -x "$(command -v apt-get)" ]; then
  echo "Found apt-get, assuming Debian family..."
  DISTRO="debian"
elif [ -x "$(command -v yum)" ]; then
  echo "Found yum, assuming Red Hat family..."
  DISTRO="redhat"
else
  echo "Unable to determine Linux distribution."
  exit 1
fi

CRON_JOB_SOURCE_DIR="/tmp/"
CRON_JOB_DESTINATION_DIR_HOURLY="/etc/cron.hourly/"
CRON_JOB_DESTINATION_DIR_DAILY="/etc/cron.daily/"
CRON_JOB_DESTINATION_DIR_WEEKLY="/etc/cron.weekly/"
CRON_JOB_DESTINATION_DIR_MONTHLY="/etc/cron.monthly/"
CRON_JOB_SOURCE_FILES_HOURLY=(
  "${CRON_JOB_SOURCE_DIR}gocd_ldap_synch"
)
CRON_JOB_SOURCE_FILES_DAILY=(
  "${CRON_JOB_SOURCE_DIR}gocd_agent_pruning"
)
CRON_JOB_SOURCE_FILES_WEEKLY=(
)
CRON_JOB_SOURCE_FILES_MONTHLY=(
)

echo "Importing hourly cron jobs..."
for CRON_JOB_SOURCE_FILE in "${CRON_JOB_SOURCE_FILES_HOURLY[@]}"
do
  if [ ! -e "${CRON_JOB_SOURCE_FILE}" ]; then
    echo "Unable to locate cron job source file '${CRON_JOB_SOURCE_FILE}'."
    exit 1
  else
    echo "Hourly job: '$(basename ${CRON_JOB_SOURCE_FILE})'"
    sudo chown root:root "${CRON_JOB_SOURCE_FILE}"
    sudo chmod 755 "${CRON_JOB_SOURCE_FILE}"
    sudo mv -f "${CRON_JOB_SOURCE_FILE}" "${CRON_JOB_DESTINATION_DIR_HOURLY}"
  fi
done

echo "Importing daily cron jobs..."
for CRON_JOB_SOURCE_FILE in "${CRON_JOB_SOURCE_FILES_DAILY[@]}"
do
  if [ ! -e "${CRON_JOB_SOURCE_FILE}" ]; then
    echo "Unable to locate cron job source file '${CRON_JOB_SOURCE_FILE}'."
    exit 1
  else
    echo "Daily job: '$(basename ${CRON_JOB_SOURCE_FILE})'"
    sudo chown root:root "${CRON_JOB_SOURCE_FILE}"
    sudo chmod 755 "${CRON_JOB_SOURCE_FILE}"
    sudo mv -f "${CRON_JOB_SOURCE_FILE}" "${CRON_JOB_DESTINATION_DIR_DAILY}"
  fi
done

echo "Importing weekly cron jobs..."
for CRON_JOB_SOURCE_FILE in "${CRON_JOB_SOURCE_FILES_WEEKLY[@]}"
do
  if [ ! -e "${CRON_JOB_SOURCE_FILE}" ]; then
    echo "Unable to locate cron job source file '${CRON_JOB_SOURCE_FILE}'."
    exit 1
  else
    echo "Weekly job: '$(basename ${CRON_JOB_SOURCE_FILE})'"
    sudo chown root:root "${CRON_JOB_SOURCE_FILE}"
    sudo chmod 755 "${CRON_JOB_SOURCE_FILE}"
    sudo mv -f "${CRON_JOB_SOURCE_FILE}" "${CRON_JOB_DESTINATION_DIR_WEEKLY}"
  fi
done

echo "Importing monthly cron jobs..."
for CRON_JOB_SOURCE_FILE in "${CRON_JOB_SOURCE_FILES_MONTHLY[@]}"
do
  if [ ! -e "${CRON_JOB_SOURCE_FILE}" ]; then
    echo "Unable to locate cron job source file '${CRON_JOB_SOURCE_FILE}'."
    exit 1
  else
    echo "Monthly job: '$(basename ${CRON_JOB_SOURCE_FILE})'"
    sudo chown root:root "${CRON_JOB_SOURCE_FILE}"
    sudo chmod 755 "${CRON_JOB_SOURCE_FILE}"
    sudo mv -f "${CRON_JOB_SOURCE_FILE}" "${CRON_JOB_DESTINATION_DIR_MONTHLY}"
  fi
done
