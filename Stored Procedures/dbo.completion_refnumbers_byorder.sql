SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[completion_refnumbers_byorder] @p_ord_hdrnumber int

AS

/**
 * 
 * NAME:
 * completion_refnumbers_byorder
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: @p_ord_hdrnumber	int	Order Header number use to look up referencenumbers
 *
 * REVISION HISTORY:
 * 7/27/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 *
 **/

Declare @desc varchar (50), @v_int int
SELECT 	@v_int = 0

--BEGIN PTS 56334 SPN
--SELECT  seq  = @v_int,   
--	completion_referencenumber.ref_type ,         
--	completion_referencenumber.ref_number ,           
--	completion_referencenumber.ref_sequence ,           
--	completion_referencenumber.ref_table ,           
--	completion_referencenumber.ref_tablekey ,           
--	completion_referencenumber.ord_hdrnumber    
--FROM 	completion_referencenumber 
--WHERE 	completion_referencenumber.ord_hdrnumber = @p_ord_hdrnumber     
SELECT seq = @v_int
     , ref_type
     , ref_number
     , ref_sequence
     , ref_table
     , ref_tablekey
     , ord_hdrnumber
  FROM referencenumber
 WHERE ord_hdrnumber = @p_ord_hdrnumber     
--END PTS 56334 SPN
 
GO
GRANT EXECUTE ON  [dbo].[completion_refnumbers_byorder] TO [public]
GO
