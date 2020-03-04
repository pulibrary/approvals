# frozen_string_literal: true
class RecurringEventsController < ApplicationController
  # GET /recurring_events
  # GET /recurring_events.json
  def index
    @recurring_events = RecurringEvent.all.order(:name).where_contains_text(search_query: index_params[:query]).limit(100)
  end

  # POST /recurring_events
  # POST /recurring_events.json
  def combine
    CombineRecurringEvents.process(combined_name: combine_params[:combined_name], selected_event_ids: combine_params[:selected_events])
    respond_to do |format|
      format.html { redirect_to recurring_events_path, flash: { success: "Your events have been combined" } }
      format.json { head :no_content }
    end
  end

  private

    def index_params
      params.permit(:query)
    end

    def combine_params
      params.permit(:combined_name, selected_events: [])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_event_params
      params.require(:recurring_event).permit(:name, :description, :url)
    end
end
