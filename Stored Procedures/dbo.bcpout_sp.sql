SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.bcpout_sp    Script Date: 6/1/99 11:54:03 AM ******/
Create Proc [dbo].[bcpout_sp] (@DBName	varchar(20))
As

	select "BCP " + @DBName + ".." + name + " out " + 
				substring(name,1,3) + right(name,5) +
				".txt -Usa -P -c -o" + 
				substring(name,1,3) + 
				right(name,5) + ".log"
	from sysobjects
	where type = 'U'
	order by name


GO
GRANT EXECUTE ON  [dbo].[bcpout_sp] TO [public]
GO
