SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_loadaddr_sp    Script Date: 6/1/99 11:54:16 AM ******/
create PROC [dbo].[d_loadaddr_sp] @type varchar(6), @name varchar(40) , @number int AS


if @number = 1 
	set rowcount 1 
else 
	set rowcount 8 

if exists ( SELECT MCA_NAME FROM MCADDRESS WHERE MCA_NAME >= @name AND MCA_NAMETYPE = @type ) 
	SELECT MCA_NAME, MCA_SERVICE, MCA_ADDRESS, MCA_DESCRIPTION
		FROM MCADDRESS
		WHERE MCA_NAME >= @name AND
		 		MCA_NAMETYPE = @type
		ORDER BY MCA_NAME
else 
	SELECT MCA_NAME, MCA_SERVICE, MCA_ADDRESS, MCA_DESCRIPTION
		FROM MCADDRESS
		WHERE MCA_NAME = "UNKNOWN" AND
				MCA_NAMETYPE = @type
set rowcount 0




GO
GRANT EXECUTE ON  [dbo].[d_loadaddr_sp] TO [public]
GO
