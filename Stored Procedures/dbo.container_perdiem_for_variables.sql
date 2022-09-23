SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[container_perdiem_for_variables]
	@owner		varchar(12),
	@port		varchar(8),
	@customer	varchar(8),
	@daysoutofport	integer
AS
/**
 * 
 * NAME:
 * container_perdiem_for_variables
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION: Given the Owner (Pay To from Trailer), Port (Shipper from Order), 
 * and Customer (Bill To from Order) the stored procedure will return the corresponding 
 * per diem.  The days out of port will be placed in the output table so that the a single
 * datawindow can be used to calculate the per diem amount as well.
 * 
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * The matching row from the per diem table.  
 *
 * PARAMETERS:
 * 001 - @owner, varchar (12), IN, NULL;
 *       The Pay To from Trailer 1 on the Order
 * 002 - @port, varhcar (8), IN, NULL
 *       The shipper from the Order
 * 003 - @customer, varhcar (8), IN, NULL
 *       The Bill To from the Order
 * 004 - @daysoutofport  , varhcar (8), IN, NULL
 *       The Number of Days the Container has been out of port
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * none

 * 
 * REVISION HISTORY:
 * 10/5/2005.01 ? PTS29965 - Greg Kanzinger ? Created Procedure
 *
 **/
BEGIN

SELECT TOP 1 *, daysoutofport = @daysoutofport FROM
       (SELECT  orderby = 1,
		cpd_id, 
		cpd_sequence, 
		cpd_owner, 
		cpd_port, 
		cpd_customer, 
		cpd_freedays, 
		cpd_days1, 
		cpd_charge1, 
		cpd_days2, 
		cpd_charge2, 
		cpd_days3, 
		cpd_charge3, 
		cpd_days4, 
		cpd_charge4,
		cpd_maxcharge, 
		cpd_incremental, 
		cpd_created_date, 
		cpd_created_user, 
		cpd_modified_date, 
		cpd_modified_user 
	FROM containerperdiem
	WHERE (cpd_owner = @owner)
	AND   (cpd_port = @port)
	AND   (cpd_customer = @customer )
	Union
	SELECT  orderby = 2,
		cpd_id, 
		cpd_sequence, 
		cpd_owner, 
		cpd_port, 
		cpd_customer, 
		cpd_freedays, 
		cpd_days1, 
		cpd_charge1, 
		cpd_days2, 
		cpd_charge2, 
		cpd_days3, 
		cpd_charge3, 
		cpd_days4, 
		cpd_charge4,
		cpd_maxcharge, 
		cpd_incremental, 
		cpd_created_date, 
		cpd_created_user, 
		cpd_modified_date, 
		cpd_modified_user 
	FROM containerperdiem
	WHERE (cpd_owner = @owner OR cpd_owner IS NULL or  cpd_owner = '' or cpd_owner = '(All)')
	AND   (cpd_port = @port OR cpd_port IS NULL or  cpd_port = '' or  cpd_port = '(All)')
	AND   (cpd_customer = @customer OR cpd_customer IS NULL or cpd_customer = '' or  cpd_customer = '(All)')) A
ORDER BY A.orderby, A.cpd_sequence
END
GO
GRANT EXECUTE ON  [dbo].[container_perdiem_for_variables] TO [public]
GO
