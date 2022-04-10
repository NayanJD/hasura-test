## Starting the server

1. Start the services

```
docker-compose up -d
```

2. Start the console server

```
hasura console
```

3. Below two queries are created as per task

```
user_by_pagination(args: {page_number: 1, page_size: 3})
```

and 

```
search_users(args: {distance: "50", i_lat: "12.85601806746186", i_lng: "77.61113968140324"}) 
```

graphql_queries.graphql contains all example queries