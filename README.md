
# Ant-Fraud API

> An Anti-fraud works by receiving information about a transaction and inferring whether it is a fraudulent transaction or not before authorizing it.


* Ruby version
  3.1.2

* Rails version
  Rails 7.0.4

* Postgre version
  PostgreSQL 12

* Redis version
  4.0

* Sidekiq version
  6.5


## 💻 How to install

To install the project on your machine, follow these steps:

* Configuration
  Install Redis-Server command bellow:
```
sudo apt-get install redis-server
```


* Clone this repository and install the dependencies with the following commands in your terminal:
```
bundle install
```
```
yarn install
```
## Database creation and initialization

run in your terminal:
```
rails db:create db:migrate
```

## Run application

run the commands below, each in a different terminal tab
```
rails s
```
```
redis-server
```
```
sidekiq
```

## Using the API

To register a transaction send a POST request with a payload like this:
```
{
"transaction_id" : 2342357,
"merchant_id" : 29744,
"user_id" : 97051,
"card_number" : "434505******9116",
"transaction_date" : "2019-11-31T23:16:32.812632",
"transaction_amount" : 373,
"device_id" : 285475
}
```

to this path:
```
http://localhost:3000/transactions
```

then receive if the transaction got approve or deny:
```
{
    "transaction_id": 2342357,
    "recommendation": "approve"
}
```

To register a chargeback send a PATCH request with the transaction_id to the path:
```
http://localhost:3000/:transaction_id
```



#### ENJOY =]
