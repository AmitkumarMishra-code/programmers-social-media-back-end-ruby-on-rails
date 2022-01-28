# Programmers Social Media Back-end

## Pre-requisites

Follow the installation guide [here](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails) to install - 
* Ruby (version 2.7.5)
* Node
* Yarn

if not already installed on your system.


## Database

Download and install PostgreSQL from [here](https://www.postgresql.org/download/)
You can follow [this tutorial](https://www.guru99.com/download-install-postgresql.html), if needed.
PS: Make a note of the username and password used for pgAdmin. We will need that in a while.


## Setting Up

* Navigate to the project directory from you preferred terminal and run the command **bundle install**. This will install all the required dependencies.
* Make a **.env** file in the project root directory and add these 2 environment variables in it. We need to assign the pgAdmin username and password to these variables and save the file.
    * **DB_USERNAME=<your_pgAdmin_username>**
    * **DB_PASSWORD=<your_pgAdmin_password>**
* After the environment variables are setup, run the command **rake db:setup**. This will create the required databases for the project.
* Once the above command is executed successfully, run the command **rake db:migrate**. This will run the required migrations on the database and create the necessary schemas.
* Once the above command is executed successfully, the project setup is complete.
* You can run the server with the command **rails server**


## Postman/Insomnia

You can use **Postman** or **Insomnia** to test the routes on your local machine. Make a note of the port number the server is running on, usually 3000, and use the address http://localhost:3000/ to test the routes.

## Live Front-end

If you want to test out a live version of the application, [here](https://quirky-mayer-656736.netlify.app/) is a link to a front-end application (hosted on netlify), that is utilising this server (hosted on heroku). You can use the credentials **username: test_user** and **password: test1234** to browse it, or sign up, if you wish to.
