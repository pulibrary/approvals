# frozen_string_literal: true

json.array! @delegators, partial: "delegates/delegator", as: :delegator
