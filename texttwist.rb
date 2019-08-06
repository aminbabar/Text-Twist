# Amin Babar
# 10/03/18
# Version: ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux]
# Text Twist
# When the user calls the play​ method, the program starts a new game. Each game 
# is composed of one or more rounds, during which the user guesses words using 6 
# specific letters. In each round, the program chooses a random 6-letter word 
# from the supplied dictionary, and useS those 6 letters as the letters for the
# round. It then finds any word in the dictionary composed entirely of 3 or more 
# of these 6 letters; these are the words that the user should guess this round. 
# The game can be quit by calling on EXIT. 

class TextTwist
	require "timeout"

	def initialize(input_file)
		dictionary = File.readlines(input_file)
		@legal_words = []

		# takes all the words in the dictionary and adds them to the list if the
		# words are greater than length 2 and smaller than length 7.
		legal_words = dictionary.map {|x| x.chomp}
		@legal_words = legal_words.select do |x| 
			x.length > 2 and x.length < 7
		end

		# creates a list of all the 6 lettered words in the dictionary
		@six_letter_words = []
		@six_letter_words = @legal_words.select do |x| 
			x.length == 6
		end

		@word_matches = []
      @words_guessed_correctly = []
      @letters_displayed = ""

      # keep track of general score over different rounds 
      @total_rounds = 0
      @total_words_guessed = 0
      @total_words_possible = 0
      @next_round = false

	end

	# Finds all the words that could be made using the combination of letters
	# in a randomly generated word that has a length of 6.
	def word_combinations
		@word_matches = []
		@start_word = @six_letter_words.sample
		@letters_displayed = @start_word.split("")
		
		# goes through all of the words that are legal (2 < length < 7), and for
		# each word it assesses whether or not all the letters in that word match
		# the letters in the randomly generated word of 6 letters. If the word
		# does contain all the letters found in the start word, it adds the word
		# to a wprd_matches list
		@legal_words.each do |x|
			start_word_letters = @start_word.split("")
			j = 0
			until j == (x.length)
				legal_word_letters = x.split("")
				if start_word_letters.include?(legal_word_letters[j])
					start_word_letters.delete_at(start_word_letters.index(legal_word_letters[j]))
					j += 1
				else
					break
				end

				if (j == x.length)
					@word_matches << x
				end
			end
		end

		# Ensures that the words are arranged by length first, and then breaks
		# the ties by alphabetical order. Relies on the fact that dictionaries
		# are already alphabetically ordered.
		@word_matches = @word_matches.reverse!
		@word_matches = @word_matches.sort_by {|x| x.length}
		@word_matches = @word_matches.reverse!

		# Creates a list with all values false, each value corresponding to the
		# word matches found for the start word.
      @words_guessed_correctly = @word_matches.map do |x|
         false
      end

	end

	# generates a human friendly string describing the object
	def to_s
		"Text twist game object"
	end

	# returns a string describing the object
	def inspect
		"Text twist game object"
	end

	# generates an output of the correct format at the start of the game. For
	# each word match to the start word, it generates "-" for each letter of the
	# word if the word has not been guessed, but if the word has been guessed, it
	# outputs the word. Each word, in form of - or letters is output to a
	# different line.
	def output
      puts "===================================="
      @word_matches.each do |x|
         if @words_guessed_correctly[@word_matches.index(x)]
            puts x
         else
            puts ("-" * x.length)
         end
      end
      puts "Number words: #{@word_matches.length}"
      puts "Correct words: #{@words_guessed_correctly.count(true)}"
      puts "Letters: #{@letters_displayed}"
	end

	# Starts a new text twist game. Each game has time contraints and has a
	# randomly generated start word.
	def play
		@next_round = false
		word_combinations
      output

      # Each round is timed at 2 minutes. For each word that the user guesses
      # corretly, it sets the value in the @words_guessed_correctly at the index
      # corresponding to the index of the word in the word_matches array to
      # true. This helps keeps track of the words guessed correctly. If guess
      # is empty, it shuffles the letters displayed for the round. Quits, if the
      # input is EXIT. Round also ends if all the words are guessed correctly.
      # Once the round ends, end_of_round_output is called upon.
      begin
      	status = Timeout::timeout(120) do
      	until @words_guessed_correctly.count(true) == @words_guessed_correctly.length do
         	print "Guess: "
         	guess = gets.chomp
         	if guess == "EXIT"               
            	break
            elsif guess == ""
            	@letters_displayed = @letters_displayed.shuffle
         	elsif @word_matches.include?(guess)
         		@words_guessed_correctly[@word_matches.index(guess)] = true
         		if guess.length == 6
         			@next_round = true
         		end
         	end
         	output
      	end
   	end

   	rescue Timeout::Error
   	end

   	end_of_round_output
 	
	end

	# Displays the output in the correct format after the round ends. Displays
	# and updates the general overall stats at the end of the round.
	def end_of_round_output
		@total_rounds += 1
		@total_words_guessed += @words_guessed_correctly.count(true)
   	@total_words_possible += @word_matches.length
   	puts ""
   	puts "===================================="
   	puts @word_matches
   	puts "===================================="
		puts "Round Stats:"
      puts "Correct words: #{@words_guessed_correctly.count(true)}"
      puts "Number words: #{@word_matches.length}"
      puts "-------------------------------------"
      puts "After #{@total_rounds} rounds:"
      puts "Total words guessed:          #{@total_words_guessed}"
      puts "Out of totall words possible: #{@total_words_possible}"
      puts "For a guess rate of:          #{(@total_words_guessed * 100) / @total_words_possible}%"

      # If atleast one 6 letter word has been guessed, the user may proceed to
      # next round, but if not, the game quits. Instance variables keeping track
      # of general stats are reset towards the end of the game.
      if @next_round
      	puts "-------------------------------------"
  			puts "You guessed at least one 6-letter word!"
			print "Would you like to play another round? (y/n):"
			input = gets.chomp
			if input == "y"
				play
			elsif input == "n"
				puts "Goodbye!"
				@total_rounds = 0
      		@total_words_guessed = 0
      		@total_words_possible = 0
      	end
		else
			puts "You did not guess a 6-letter word, so you don't get to play another round."
			puts "Goodbye!"
			@total_rounds = 0
      	@total_words_guessed = 0
      	@total_words_possible = 0
		end
	end

end
