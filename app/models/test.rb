class Test < ApplicationRecord
  belongs_to :suite
  has_many :steps, dependent: :destroy
  has_many :assertions, dependent: :destroy
  has_many :test_params, dependent: :destroy

  has_many :prep_tests, dependent: :destroy
  has_many :lead_steps, :through => :prep_tests, :source => :step
  has_many :lead_suites, :through => :prep_tests, :source => :suite
  has_many :generation_events, dependent: :destroy

  validates :title, :name, presence: true
  validates :session_id, uniqueness: true, if: 'session_id.present?'

  serialize :cachesteps, Hash

  def url
    "/test/#{name}/#{id}"
  end

  def code_file_name(language)
    hash = Digest::MD5.hexdigest "#{ENV['RDS_HOSTNAME']}-#{id}"
    languages = {'ruby'=>'rb', 'python'=>'py', 'java'=>'java', 'javascript'=>'js'}
    "#{hash}.#{languages[language.downcase]}"
  end

  def code_url(language)
    "https://s3.amazonaws.com/#{ENV['bucket']}/#{code_file_name language}"
  end
end
