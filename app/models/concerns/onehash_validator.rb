class OnehashValidator < ActiveModel::Validator
  def validate(record)
    counter = record.body.scan(/# /).length
    if counter > 0
      record.errors.add(:body, "Empty tag found")
    end

    counter = record.body.count("#")
    if counter != 1
      record.errors.add(:body, "#{counter} tags, where should be exactly 1")
    end
  end
end
