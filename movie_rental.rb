# You are writing code for a company that builds software to track and invoice for movie rentals
# and are asked to add a new billing rule for classic movies.  Renting a classic movie costs $1 per day and has no fixed rental cost.
# The codebase works, but was originally written by a junior engineer and the code is found below.  Refactor the
# code as you see necessary and add the new billing rule.  Be prepared to talk through your refactoring decisions.

# We will check that the code works, but are more interested in the refactoring decisions you make.

# original example usage:
# $ irb
# > require_relative 'duco_tech_debt_2'
# > movie1 = Movie.new('First Movie', Movie::REGULAR)
# > movie2 = Movie.new('Second Movie', Movie::NEW_RELEASE)
# > movie3 = Movie.new('Third Movie', Movie::CHILDRENS)
# > customer = Customer.new("Scott")
# > rental1 = Rental.new(movie1, 3)
# > customer.add_rental(rental1)
# > rental2 = Rental.new(movie2, 4)
# > customer.add_rental(rental2)
# > rental3 = Rental.new(movie3, 5)
# > customer.add_rental(rental3)
# > customer.statement
#
# refactored example usage
#
# you can run ```ruby test_script.rb ``` to test data output
# but you man need to install test-unit
#
# require_relative 'movie_rental'
# movie1 = Movie.new('First Movie', :REGULAR)
# movie2 = Movie.new('Second Movie', :NEW_RELEASE)
# movie3 = Movie.new('Third Movie', :CHILDRENS)
# movie4 = Movie.new('Fourth Movie', :CLASSIC)
# customer = Customer.new("Scott")
# rental1 = Rental.new(movie1, 3)
# customer.add_rental(rental1)
# rental2 = Rental.new(movie2, 4)
# customer.add_rental(rental2)
# rental3 = Rental.new(movie3, 5)
# customer.add_rental(rental3)
# rental4 = Rental.new(movie4, 6)
# customer.add_rental(rental4)


class Movie

  @@price_codes = {CHILDRENS: {base: 1.5, discount_price: 1.5, included_days: 3},
                   NEW_RELEASE: {base: 3, discount_price: nil, included_days: nil},
                   REGULAR: {base: 2, discount_price: 1.5, included_days: 2,},
                   CLASSIC: {base: 1, discount_price: nil, included_days: nil}}

  # @@price_genre = [GenrePrice.new(:CHILDRENS, 1.5, 1.5, 3)]

  attr_accessor :price_code, :title

  def initialize(title, price_code)
    @title = title
    if @@price_codes[price_code]
      @price_code = price_code
    else
      raise "No price code exists for #{price_code}."
    end
  end

  def self.price_codes
    return @@price_codes
  end

end

class Rental

  attr_accessor :days_rented, :movie
  def initialize(movie, days_rented)
    @movie = movie
    @days_rented = days_rented
  end

end

class Customer

  attr_accessor :name, :statement_data
  attr_reader :rentals

  def initialize(name)
    @rentals = []
    @name = name
  end

  def add_rental(movie)
    @rentals << movie
  end

  def statement
    statement = Statement.new(self)
    @statement_data = statement.calculate_statement
    statement.print_statement
    statement
  end

end

class Statement

  attr_reader :statement_data, :customer

  def initialize(customer)
    @customer = customer
    @statement_data = {}
  end

    def calculate_statement
      total = 0
      frequent_renter_points_total = 0
      @customer.rentals.each do |rental|
        totals_for_rental = calculate_rental_data(rental)
        cost_of_rental = totals_for_rental[:due]
        points_for_rental = totals_for_rental[:points]
        total += cost_of_rental
        frequent_renter_points_for_rental = points_for_rental
        frequent_renter_points_total += points_for_rental
        @statement_data[rental.movie.title] = {due: cost_of_rental, points: frequent_renter_points_for_rental}
      end
      @statement_data['total_cost'] = total
      @statement_data['total_points'] = frequent_renter_points_total
    end

    def calulate_price_for_rental(rental)
      total = 0
      price_code = rental.movie.price_code
      included_days = Movie.price_codes[price_code][:included_days]
      discount_price = Movie.price_codes[price_code][:discount_price]
      base_price = Movie.price_codes[price_code][:base]
      days_rented = rental.days_rented

      if discount_price  && (days_rented > included_days)
        total += base_price
        extra_days_to_charge = days_rented - included_days
        total += extra_days_to_charge * discount_price
      else
        total = days_rented * base_price
      end
    end

    def calculate_frequent_renter_points(rental)
      # Add frequent renter points
      frequent_renter_points = 1
      price_code = rental.movie.price_code
      # Add a bonus point for a new release rental over 2 days
      if price_code == :NEW_RELEASE && rental.days_rented > 1
        frequent_renter_points += 1
      end
      frequent_renter_points
    end

    def calculate_rental_data(rental)
      total_for_rental = calulate_price_for_rental(rental)
      frequent_renter_points = calculate_frequent_renter_points(rental)
      {due: total_for_rental, points: frequent_renter_points}
    end

    def print_statement
      result = "Rental record for #{@customer.name}\n\n"
      totals = ['total_cost', 'total_points']

      @statement_data.each do |key, values|
        if !totals.include?(key)
          result += "#{key} \t cost #{values[:due]} \n"
          result += "You earned #{values[:points]} frequent renter #{points_plural_helper(values[:points])}. \n"
        end
      end

      result += "\n"
      result += "The total amount owed is #{@statement_data["total_cost"]} \n"
      result += "During this billing cycle you have earned #{@statement_data["total_points"]} " + "frequent renter #{points_plural_helper(@statement_data["total_points"])}."
      result += "\n"
      puts result
    end

    def points_plural_helper(num)
      num > 1 ? "points" : "point"
    end

end
