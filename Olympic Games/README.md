### Dataset

The input dataset (CSV files) is available in this repository:

https://github.com/tugraz-isds/datasets/tree/master/summer_olympics

### Run MariaDB

Start Mariadb using docker and docker-compose: 

```
docker-compose up
```

Connect to MariaDB as follows:

```
docker-compose exec -it db mariadb  
```

Press CTR+C to stop the container. Then, execute the following instruction to free your resources: 

```
docker-compose down
```


