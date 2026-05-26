# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      # Adds one custom field per column in export if custom fields are activted
      # Adds vote weights
      module ProposalSerializerOverride
        extend ActiveSupport::Concern

        included do
          include ProposalSerializerMethods

          alias_method :decidim_original_serialize, :serialize

          def serialize
            # serialize first the custom fields,
            # as default serialization will strip proposal body's <xml> tags.
            serialization = decidim_original_serialize
            serialization.merge!(proposal_vote_weights)
            serialization.merge!(serialize_custom_fields)
          end

          protected

          # Override the standard `:votes` column with the weighted breakdown
          # whenever the component currently uses a weighted manifest, OR
          # weighted votes already exist (e.g. left over from a previous
          # configuration). When neither is true, return an empty payload so
          # Decidim core's integer vote count is left in place.
          def proposal_vote_weights
            proposal.update_vote_weights!
            weights = proposal.reload.vote_weights
            return {} if weights.blank? && !awesome_voting_manifest_for(proposal.component)&.weighted?

            { votes: weights }
          end
        end
      end
    end
  end
end
