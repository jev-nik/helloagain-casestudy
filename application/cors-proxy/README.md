docker build -t cors-proxy:latest .

dockeer images

docker ps

docker stop 

Zum testen:
docker run -p 8080:8080 cors-proxy:latest

curl -v -H "Origin: http://example.com" http://localhost:8080/https://jsonplaceholder.typicode.com/posts/1

