SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.load_taxtype_sp    Script Date: 6/1/99 11:54:36 AM ******/
create PROC [dbo].[load_taxtype_sp] @name varchar(20) AS

Declare @retval varchar(20)


if exists(select * from labelfile where labeldefinition = @name)
     BEGIN

	SELECT  min ( labelfile.userlabelname ) , 
		min ( labelfile.labeldefinition ) 
	FROM 	labelfile  
	WHERE 	( labelfile.userlabelname > '' ) AND
		( labelfile.labeldefinition  = @name )
     END

else
     BEGIN
	
	if @name ='TaxType1'
	   select @retval = 'Federal'	
	else if @name = 'TaxType2'
	   select @retval = 'Provincial'
	else if @name = 'TaxType3'
	   select @retval = 'Tax 3'
	else 
	   select @retval = 'Tax 4'


	select @retval,@name		

     END 
	





GO
GRANT EXECUTE ON  [dbo].[load_taxtype_sp] TO [public]
GO
