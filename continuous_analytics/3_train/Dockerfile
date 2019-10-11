FROM python:3

WORKDIR /usr/src/

COPY requirements.txt .
COPY train.py .
COPY read_data.py .

RUN mkdir /input
RUN mkdir /output

RUN pip install -r requirements.txt

CMD [ "python", "./train.py" ]
