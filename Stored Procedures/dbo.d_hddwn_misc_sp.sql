SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_misc_sp    Script Date: 6/1/99 11:54:46 AM ******/
/****** Object:  Stored Procedure dbo.d_hddwn_misc_sp    Script Date: 8/20/97 1:57:30 PM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_misc_sp](@v_ordnumber int)
                                 

AS

--*********************************************************************************************
--Declaration and initialization of variables

--*********************************************************************************************
select distinct  orderheader.ord_bookdate,
       orderheader.ord_hdrnumber,
       orderheader.ord_description,
       stops.lgh_number,
	orderheader.ord_revtype1,	 	
	orderheader.ord_revtype2,	 	
	orderheader.ord_revtype3,	 	
	orderheader.ord_revtype4
       
  into #misc

  from orderheader,stops

 where orderheader.ord_hdrnumber = @v_ordnumber and stops.ord_hdrnumber = @v_ordnumber and
       orderheader.ord_hdrnumber = stops.ord_hdrnumber

--********************************************************************************************** 

SELECT *
 FROM #misc


GO
GRANT EXECUTE ON  [dbo].[d_hddwn_misc_sp] TO [public]
GO
