# GetReceiptsListService
# Collects receipts and incomes, and set to hash.

class GetReceiptsListService
  def initialize(book_id, year, month)
    @book = Book.find(book_id)
    @year = year
    @month = month
  end

  def exec
    showing_start = Date.new(@year, @month, 1)
    showing_end = Date.new(@year, @month, -1)

    incomes = @book.incomes.where("pay_date >= ? and pay_date <= ?", showing_start, showing_end)
    receipts = @book.receipts.where("pay_date >= ? and pay_date <= ?", showing_start, showing_end)
    monthlyinputs = @book.monthlyinputs.where("start_date <= ? and end_date >= ?", showing_start, showing_start)

    incomes_array = []
    receipts_array = []

    # total result of incomes/receipts
    total_receipts = 0
    total_incomes = 0

    # add monthly inputs
    monthlyinputs.each do |m|
      new_input = {
        store_id: m.store_id,
        price: m.price,
        pay_date: Date.new(year, month, m.pay_date),
      }

      if m.is_income
        data = @book.incomes.new(new_input)
        incomes_array.push(data)
        total_incomes = total_incomes + m.price
      else
        data = @book.receipts.new(new_input)
        receipts_array.push(data)
        total_receipts = total_receipts + m.price
      end
    end

    # add incomes
    incomes.each do |income|
      incomes_array.push(income)
      total_incomes = total_incomes + income.price
    end

    #add receipts
    receipts.each do |receipt|
      receipts_array.push(receipt)
      total_receipts = total_receipts + receipt.price
    end

    total_balance = (total_incomes - total_receipts)

    result = {
      total_balance: total_balance,
      total_incomes: total_incomes,
      total_receipts: total_receipts,
      incomes: incomes_array,
      receipts: receipts_array,
    }

    result
  end
end
