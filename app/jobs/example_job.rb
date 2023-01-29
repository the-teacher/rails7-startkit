# frozen_string_literal: true

class ExampleJob < ApplicationJob
  queue_as :default

  # ExampleJob.perform_now
  # ExampleJob.perform_later
  # ExampleJob.set(wait: 1.week).perform_later()
  def perform(*_args)
    puts 'Job is Started'
    sleep(10)
    puts 'Job is Finished'
  end
end
