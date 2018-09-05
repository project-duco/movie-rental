require_relative 'movie_rental'
require 'test/unit'


class TestMovieRental < Test::Unit::TestCase

  def setup
    movie1 = Movie.new('First Movie', :REGULAR)
    movie2 = Movie.new('Second Movie', :NEW_RELEASE)
    movie3 = Movie.new('Third Movie', :CHILDRENS)
    movie4 = Movie.new('Fourth Movie', :CLASSIC)
    customer = Customer.new("Scott")
    rental1 = Rental.new(movie1, 3)
    customer.add_rental(rental1)
    rental2 = Rental.new(movie2, 4)
    customer.add_rental(rental2)
    rental3 = Rental.new(movie3, 5)
    customer.add_rental(rental3)
    rental4 = Rental.new(movie4, 6)
    customer.add_rental(rental4)
    customer.statement
  end

  def test_output
    statement = setup
    data = statement.statement_data

    # verify original data out put is the same

    assert data['First Movie'][:due] == 3.5
    assert data['First Movie'][:points] == 1

    assert data['Second Movie'][:due] == 12
    assert data['Second Movie'][:points] == 2

    assert data['Third Movie'][:due] == 4.5
    assert data['Third Movie'][:points] == 1


    # verify new price code calculates as expected

    assert data['Fourth Movie'][:due] == 6
    assert data['Fourth Movie'][:points] == 1

    # verify totals line up with original + new price code example

    assert data['total_cost'] == 26.0
    assert data['total_points'] == 5

  end

end