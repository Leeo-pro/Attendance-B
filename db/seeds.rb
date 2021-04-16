# coding: utf-8

User.create!(
  [
    {
             name: "管理者",
             email: "admin@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: 1,
             admin: true,
    },
    {
             name: "上長A",
             email: "superior-a@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: 2,
             superior: true,
    },
    {
             name: "上長B",
             email: "superior-b@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: 3,
             superior: true,
    }
  ]
)

60.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  employee_number = "#{n+1}"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_number: employee_number)
end