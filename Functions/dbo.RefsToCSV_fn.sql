SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  FUNCTION [dbo].[RefsToCSV_fn](@table varchar(20),@key int,@withTYpes varchar(50))
RETURNS  VARCHAR(255)

AS
BEGIN
    declare @refs varchar(255)
	select @refs = ''
    
    SELECT 
    @refs = @refs + ', ' + (CASE @withTYpes WHEN 'WITHTYPES' then ref_type + ' ' else '' end )+ ref_number 
    FROM referencenumber
    where ref_table = @table and ref_tablekey = @key

    if datalength(@refs) > 2
      select @refs = substring(@refs,2, datalength(@refs) - 1)
  
	RETURN @refs
END
GO
GRANT EXECUTE ON  [dbo].[RefsToCSV_fn] TO [public]
GO
