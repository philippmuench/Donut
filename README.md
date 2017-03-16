# easycircos

based on docker container from dennishazelett 

# usuage

put your circos data to the `data/` folder, then create the plot using following command

```
docker run -v /home/github.com/philippmuench/easycircos/data:/data philippmuench/easycircos
```

the circos file will be written to the `data/` folder

