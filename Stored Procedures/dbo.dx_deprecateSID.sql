SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
   This proc is called to add the information
   for a reference number on an existing order record.

   It must be called once for each reference number
   
ERROR RETURN  CODES 
   -1 database error
   -2 cannot locate any order data for this order number
   -3 no ref type passed
   
   

ARGUMENTS

  @ord_number varchar(12) - required. 

  

*/

CREATE    PROC [dbo].[dx_deprecateSID]
	@ref_table varchar(18),
	@ref_key int,
	@ref_type varchar(6),
	@ref_number varchar(30),
	@ref_sid char(1) = '',
	@ref_update varchar(30) = '',
	@ord_orderby varchar(8) = ''
AS

DECLARE  @ref_sequence int, @retcode int
  
 
  SELECT @ref_sequence = (SELECT MAX(ref_sequence)
                         FROM referencenumber
                         WHERE ref_table = 'orderheader'
			 AND ref_tablekey = @ref_key)

     SELECT @ref_sequence = @ref_sequence + 1

  IF @ref_type = '' RETURN -3

	UPDATE referencenumber
	   SET ref_sid = null,
			ref_sequence = @ref_sequence,
			ref_type = 'OLDSID'
	 WHERE ref_table = @ref_table 
	   AND ref_tablekey = @ref_key 
	   and ref_type = 'SID'
	   AND ref_sequence = 1

--if first ref num wasn't SID, just push the sequence
  UPDATE referencenumber
	   SET ref_sid = null,
			ref_sequence = @ref_sequence
	 WHERE ref_table = @ref_table 
	   AND ref_tablekey = @ref_key 
	   AND ref_sequence = 1


    UPDATE orderheader
    SET ord_reftype = @ref_type , ord_refnum = @ref_number
    WHERE ord_hdrnumber = @ref_key 

    /* add  order ref numbers */
 
  IF NOT EXISTS (SELECT 1 FROM referencenumber 
       WHERE ref_tablekey = @ref_key AND ref_table = 'orderheader' 
	 AND ref_type = @ref_type AND ref_number = @ref_number)
    INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ord_hdrnumber,
	ref_table,
	ref_sid,
	ref_pickup)
    VALUES  (@ref_key,
	@ref_type,
	@ref_number,
	1,
	@ref_key,
	'orderheader',
	@ref_sid,
	Null)

  SELECT @retcode = @@error
  IF @retcode<>0
	return -1


  RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_deprecateSID] TO [public]
GO
