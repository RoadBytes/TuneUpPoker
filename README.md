# Tune Up: Poker

* [here is a link to the repo for this challenge](https://github.com/RoadBytes/TuneUpPoke://github.com/RoadBytes/TuneUpPoker)

Hello World!  This is the first of hopefully many coding challenges with
RoadBytes.  A general description of tunes ups can be found here:

[TODO: add link to tuneup description]

In [Launch School](https://launchschool.com), I was given a challenge to create
a poker hand application that would take in a series of poker hands and return
the highest hands.

# Specs

* Input

Hands would be in the form of an array with to character strings. ie.

~~~
high_of_jack = %w(4S 5S 7H 8D JC)
high_of_queen = %w(2S 4H 6S TD QH)
~~~

There will just be one argument consisting of an array of hands.

~~~
Poker.new([high_of_8, high_of_queen])
~~~

* Output

Simply consists of an array with the highest hands from the input.  There can be
ties.  See more details on Poker rules on
[wiki](https://en.wikipedia.org/wiki/List_of_poker_hand_categories)

~~~
[high_of_queen]
~~~

* See the `test.rb` file from the repo for more information.

# Challenge

If you look at the `poker.rb` file, when I implemented this challenge, I made a
method `Poker#best_hand` that didn't really fit in the Poker class.

~~~
  def best_hand
    # TODO: remove this from Poker
    # consider how it touches everything
    best_hands = best_ranked_hands
    highest_card_value = 0
    best_hands.each do |hand|
      high_hand_value = hand.max_card_value
      if high_hand_value > highest_card_value
        highest_card_value = high_hand_value
      end
    end
    best_hands.select { |hand| hand.max_card_value == highest_card_value }
              .map(&:input)
  end
~~~

[TODO: add question toggle functionality here]

## Question

Take a look at the Poker file and the method above and think of some reasons why
it might be too complex

## Answer

Just my opinion

* Poker should deal with `Hand` and not necessarily `Hand#max_card_value`
* There are levels of indentation that may be avoided
* Working a collection of `Hand`s may be best dealt with in the `Hand` class

What do you think?  Did you come up with other ways of thinking?

> Your mission, should you choose to accept it, refactor `Poker#best_hand` in a
> way that would be more sensible.

After you finish, you can compare your work with my answer, :)

