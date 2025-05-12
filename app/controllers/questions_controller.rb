class QuestionsController < ApplicationController
  before_action :set_question, only: %i[show ]

  # GET /questions or /questions.json
  def index
    @questions = Question.order(created_at: :desc) # 新しい順で並べる
  end

  # GET /questions/1 or /questions/1.json
  def show
    @question = Question.find(params[:id])
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # POST /questions or /questions.json
  def create
    @question = Question.new(question_params)
    @question.user = current_user # ユーザーがログインしていれば、ユーザーIDを関連付け

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def question_params
      params.require(:question).permit(:content, :user_id)
    end
end