import datetime
import time
from datetime import timezone

import click
from kaggle.api.kaggle_api_extended import KaggleApi


@click.command()
@click.argument("competition")
@click.option("--interval", "-i", default=60, help="Polling interval in seconds")
def main(competition: str, interval: int) -> None:
    """Check the status of the latest submission for a Kaggle competition.

    COMPETITION: The Kaggle competition name (e.g., 'titanic')
    """
    api = KaggleApi()
    api.authenticate()

    result_ = api.competition_submissions(competition)[0]
    latest_ref = str(result_)  # 最新のサブミット番号
    print(result_.url)
    submit_time = result_.date

    status = ""

    while status != "complete":
        list_of_submission = api.competition_submissions(competition)
        for result in list_of_submission:
            if str(result.ref) == latest_ref:
                break
        status = result.status

        now = datetime.datetime.now(timezone.utc).replace(tzinfo=None)
        elapsed_time = int((now - submit_time).seconds / 60) + 1
        if status == "complete":
            print("\r", f"run-time: {elapsed_time} min, LB: {result.publicScore}")
        else:
            print("\r", f"elapsed time: {elapsed_time} min", end="")
            time.sleep(interval)


if __name__ == "__main__":
    main()
