# -*- coding: utf-8 -*-
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :record_properties
  belongs_to :box, optional: true
  
  validates :username, presence: true, length: {maximum: 255}, uniqueness: true
  # Rails 5.1: Removed validates :box, existence: true - belongs_to :box, optional: true handles this
  validate :correct_igsn_prefix, if: -> { prefix.present? }  # Rails 4.2: use :if instead of :allow_nil

  alias_attribute :admin?, :administrator
  
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end
  
  def as_json(options = {})
    super({:methods => :box_global_id}.merge(options))
  end

  def box_global_id
    box&.global_id
  end

  protected

  def correct_igsn_prefix
    if prefix.present?
	errors.add(:prefix, 'The prefix must begin with "GF" and end with three characters, i.e. "GFABC" or "GFC12" ') unless prefix =~ %r{\AGF}
    end
  end

  def email_required?
    false
  end
  
end
