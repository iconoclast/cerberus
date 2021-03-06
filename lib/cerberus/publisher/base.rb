require 'cerberus/constants'

module Cerberus
  module Publisher
    class Base
      def self.formatted_message(state, manager, options)
        subject = 
        case state.current_state
        when :setup
          "Cerberus set up for project (#{manager.scm.current_revision})"
        when :broken
          additional_message = nil
          if state.previous_brokeness and state.current_brokeness
            additional_message =
            case
              when state.previous_brokeness > state.current_brokeness
                ' but getting better'
              when state.previous_brokeness < state.current_brokeness
                ' and getting worse'
            end
          end
          "Build still broken#{additional_message} (#{manager.scm.current_revision})"

        #FIXME instead of using last author as person that broken build try to guess it. I.e. only if one author since last commit did commit - then he broken it.
        when :failed
          "Build broken by #{manager.scm.last_author} (#{manager.scm.current_revision})"
        when :revival
          "Build fixed by #{manager.scm.last_author} (#{manager.scm.current_revision})"
        when :successful
          "Build successful (#{manager.scm.current_revision})"
        else                              
          raise "Unknown build state '#{state.current_state.to_s}'"
        end

        subject = "[#{options[:application_name]}]#{options[:publisher, :extra_subject]} #{subject}"
        generated_by = "--\nThis email generated by Cerberus tool ver. #{Cerberus::VERSION}, http://cerberus.rubyforge.org/"
        body = [ manager.scm.last_commit_message ]
        if options[:changeset_url]
          body << options[:changeset_url] + manager.scm.current_revision.to_s + "\n"
        end
        body += [ manager.builder.output, generated_by ]

        return subject, body.join("\n")
      end
    end
  end
end
