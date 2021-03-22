class Attendance < ApplicationRecord
  belongs_to :user
  require 'csv'
  
  attr_accessor :change
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :overwork, length: { maximum: 50 }
  validates :person, length: { maximum: 50 }

  validates :over_work_end_time, presence: true, on: [:update_over_work, :edit_over_work]
  validates :person, presence: true, on: [:update_over_work, :edit_over_work]
  
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 退勤時間が存在しない場合、出勤時間は無効（当日は除外）
  validate :started_at_is_invalid_without_a_finished_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_is_invalid_without_a_finished_at
    if Date.current != worked_on
      errors.add(:started_at, "が必要です") if started_at.present? && finished_at.blank?
    end
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  def test
    errors.add(:over_work_end_time, "が空白です") if over_work_end_time.hour.blank?
  end
  
end
