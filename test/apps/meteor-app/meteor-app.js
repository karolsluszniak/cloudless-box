Users = new Mongo.Collection('users');

if (Meteor.isClient) {
  Template.home.helpers({
    count: function () {
      return Users.find().count();
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    if (Users.find().count() < 1) {
      Users.insert({
        createdAt: new Date()
      });
    }
  });
}
