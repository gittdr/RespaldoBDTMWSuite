SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- Return the active flags for the order by, origin, destination, and bill to companies on an order
CREATE procedure [dbo].[d_companyactive_sp]
	@OBCompany varchar(8), @OCompany varchar(8), @DCompany varchar(8), @BTCompany varchar (8) 
as


SELECT  OBActive = MIN( 
  Case 
    When cmp_id = @OBCompany Then cmp_active
    Else 'Y'
  End),
	OActive =	 MIN(
  Case
    When cmp_id = @OCompany Then cmp_active
    Else 'Y'
  End),
  	DActive =	MIN(
  Case
    When cmp_id = @DCompany Then cmp_active
    Else 'Y'
  End),
  	BTActive =	MIN(
  Case
    When cmp_id = @BTCompany Then cmp_active
    Else 'Y'
  End)
From company
WHERE cmp_id in (@OBCompany,@OCompany,@DCompany,@BTCompany)

GO
GRANT EXECUTE ON  [dbo].[d_companyactive_sp] TO [public]
GO
