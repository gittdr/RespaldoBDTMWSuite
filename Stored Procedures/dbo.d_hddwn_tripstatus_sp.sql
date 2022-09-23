SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_tripstatus_sp    Script Date: 6/1/99 11:54:12 AM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_tripstatus_sp](@v_legnumber int)
                                 

AS

--*********************************************************************************************
--Declaration and initialization of variables

--*********************************************************************************************
select lgh_type1,
       lgh_outstatus,
       lgh_number
       
  into #tripstatus

  from legheader

 where legheader.lgh_number = @v_legnumber 

--********************************************************************************************** 

SELECT *
 FROM #tripstatus

GO
GRANT EXECUTE ON  [dbo].[d_hddwn_tripstatus_sp] TO [public]
GO
