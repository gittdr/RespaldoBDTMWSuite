SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/****** Object:  Stored Procedure dbo.bcpin_sp    Script Date: 6/1/99 11:54:03 AM ******/
Create Proc [dbo].[bcpin_sp] (@DBName	varchar(20))
As
	select "BCP " + @DBName + ".." + name + " in " + 
			substring(name,1,3) + right(name,5) +
			".txt -Usa -P -SSYBASE_NT -c -o" + 
			substring(name,1,3) + 
			right(name,5) + ".log"
	from sysobjects
	where type = 'U'
	order by name


GO
GRANT EXECUTE ON  [dbo].[bcpin_sp] TO [public]
GO
