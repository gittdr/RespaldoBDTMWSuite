SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create procedure [dbo].[d_duedatediscountdate_sp]  (@P_DOCDATE DATETIME, @P_TYPE int , @P_DAYS INT)  as

/*
Name:
dbo.d_duedatediscountdate_sp

Type:
[StoredProcedure]

Description:
This procedure determines a due date based on type of payment terms -- Used with a GP database

Returns:
Due Date 

Paramaters:
001 - @P_DOCDATE DATETIME, input null;
	this paramater indicates the original date of the document.

002 - @P_TYPE int,  input null;
	this paramter indicates the type of terms to be used
	1-net days
	2-day certain
	3-End of month	
        4-day certain for the following month
	0-No terms return original date
003 - @P_DAYS INT,  input null;
	this paramater indicates the date certain if using type 2, or number of days if type 1
References:
 Calls001    ? NONE
 CalledBy001 ? NONE

NOTE:  
This Proc is to be run against the Great Plains Database
see GP sy03300 table for types of Terms

Revision History
08/26/05.01 Ken Mader  - Creation

*/


DECLARE @V_DATE  DATETIME

--TYPE 1 IS NUMBER OF DAYS FROM THE DAY PASSED IN
if   @P_TYPE  = 1
begin
	select @v_DATE =  DATEADD(DD, @P_DAYS, @P_DOCDATE)

end
--TYPE 2 IS A DAY CERTAIN
else if @P_TYPE = 2 
begin

	if day (@P_DOCDATE) < @P_DAYS
	begin
		select @v_DATE = DATEADD ( DD , @P_DAYS -  day (@P_DOCDATE) , @P_DOCDATE ) 
	END 
	ELSE
	BEGIN
		select @v_DATE = DATEADD ( DD , @P_DAYS -  day (@P_DOCDATE) , @P_DOCDATE ) 
		select @v_DATE = DATEADD ( MM , 1 , @v_DATE ) 
	END 


end     
--TYPE 3 end of month   
else if @P_TYPE = 3
begin
	IF  MONTH(@P_DOCDATE) IN (1, 3, 5, 7, 8, 10, 12) 
	BEGIN
		if datepart (dd, @P_DOCDATE) = 31
			begin
				select @v_DATE = DATEADD ( mm , 1 , @P_DOCDATE )
			end	 
		else
			begin
				select @v_DATE = DATEADD ( DD , 31 -  day (@P_DOCDATE) , @P_DOCDATE )
			end
	END 		
	IF  MONTH(@P_DOCDATE) IN (4, 6, 9, 11)
	BEGIN 
		if datepart (dd, @P_DOCDATE) = 30
			begin
				select @v_DATE = DATEADD ( mm , 1 , @P_DOCDATE )
			end	
		else
			begin
				select @v_DATE = DATEADD ( DD , 30 -  day (@P_DOCDATE) , @P_DOCDATE )
			end
	END
	IF  MONTH(@P_DOCDATE) = 2
	BEGIN
		IF CAST(YEAR (@P_DOCDATE) AS int) % 4 = 0
		BEGIN 
			if datepart (dd, @P_DOCDATE) = 29
				begin
					select @v_DATE = DATEADD ( mm , 1 , @P_DOCDATE )
					select @v_DATE = DATEADD ( DD , 2 , @P_DOCDATE )
				end	
			else
				begin
					select @v_DATE = DATEADD ( DD , 29 -  day (@P_DOCDATE) , @P_DOCDATE )
				end
		END
		ELSE 
		BEGIN
			if datepart (dd, @v_DATE) = 28
				begin
					select @v_DATE = DATEADD ( mm , 1 , @P_DOCDATE )
					select @v_DATE = DATEADD ( DD , 3 , @P_DOCDATE )
				end
			else
				begin
					select @v_DATE = DATEADD ( DD , 28 -  day (@P_DOCDATE) , @P_DOCDATE )
				end	
		END 
	END 	
end
--TYPE 4 IS A DAY CERTAIN for the following month
else if @P_TYPE = 4
begin

		select @v_DATE = DATEADD ( DD , @P_DAYS -  day (@P_DOCDATE) , @P_DOCDATE ) 
		select @v_DATE = DATEADD ( MM , 1 , @v_DATE ) 

end
 

else 
begin

select @v_DATE = @P_DOCDATE 
end

SELECT @v_DATE
GO
GRANT EXECUTE ON  [dbo].[d_duedatediscountdate_sp] TO [public]
GO
