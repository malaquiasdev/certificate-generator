package main

import (
	"ekoa-certificate-generator/config"
	"ekoa-certificate-generator/internal/db"
	models "ekoa-certificate-generator/internal/db/model"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handlerIndexer(ev events.SQSEvent) error {
	cert := models.Certificate{}

	c := config.LoadConfig(false)
	db, err := db.NewClient(c.AWS)
	if err != nil {
		log.Fatal("ERROR: failed to connect with DynamoDB", err)
		return err
	}

	err = json.Unmarshal([]byte(ev.Records[0].Body), &cert)
	if err != nil {
		log.Fatal(err)
		panic(err)
	}

	cert.SetCreatedAt()
	cert.SetUpdatedAt()

	item, err := db.CreateOrUpdate(cert, c.AWS.DynamoTableName)
	if err != nil {
		log.Fatal("ERROR: CreateOrUpdate", err)
		panic(err)
	}
	log.Printf("INFO: item - %+v\n", item)

	return nil
}

func main() {
	lambda.Start(handlerIndexer)
}
