def bracket
  array1 = []
  array2 = []

  GameData::Species.each do |s|
    next if s.form > 0
    array1.push(s.id)
  end

  until array1.length + array2.length == 1
    until array1.length < 2
      mon1 = array1.sample
      array1.delete(mon1)
      mon2 = array1.sample
      array1.delete(mon2)

      result = (rand(2) == 0 ? mon1 : mon2)

      array2.push(result)
    end

    if array1.length == 1
      array2.push(array1[0])
      array1.delete(array1[0])
    end

    until array2.length < 2
      mon1 = array2.sample
      array2.delete(mon1)
      mon2 = array2.sample
      array2.delete(mon2)

      result = (rand(2) == 0 ? mon1 : mon2)

      array1.push(result)
    end

    if array2.length == 1
      array1.push(array2[0])
      array2.delete(array2[0])
    end
  end

  return (array1.length > 0 ? array1[0] : array2[0])
end