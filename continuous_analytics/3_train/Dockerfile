FROM python:3

COPY . /usr/src/
WORKDIR /usr/src/

RUN mkdir /input
RUN mkdir /output

RUN pip install -r requirements.txt

CMD [ "python", "./train.py" ]
