SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_SafetyCost_sp] @srpID int 
As
/* 
SR 17782 DPETE created 10/13/03 for retrieving and maintaining safety cost for a safetyreport
  Assume it will be filtered for the indiviual entry (accident, injury,incident)  

*/



Select sc_ID,
  srp_ID,
  sc_Sequence,
  sc_DateEntered,
  sc_DateOfService,
  sc_DescOfService,
  sc_PaidByCmp,
  sc_PaidByIns,
  sc_RecoveredCost,
  sc_CostType1 = IsNull(sc_CostType1,'UNK'), sc_CostType1_t = 'SafetyCostType1',
  sc_COstType2 = IsNull(sc_CostType2,'UNK'),sc_CostType2_t = 'SafetyCostType2',
  sc_string1,
  sc_string2,
  sc_string3,
  sc_string4,
  sc_string5,
  sc_number1,
  sc_number2,
  sc_number3,
  sc_number4,
  sc_number5,
  sc_date1,
  sc_date2,
  sc_date3,
  sc_date4,
  sc_date5,
  sc_CostType3 = IsNull(sc_CostType3,'UNK'),sc_CostType3_t = 'SafetyCostType3',
  sc_COstType4 = IsNull(sc_CostType4,'UNK'),sc_CostType4_t = 'SafetyCostType4',
  sc_CostType5 = IsNull(sc_CostType5,'UNK'),sc_CostType5_t = 'SafetyCostType5',
  sc_CostType6 = IsNull(sc_CostType6,'UNK'),sc_CostType6_t = 'SafetyCostType6'
From SafetyCost
Where srp_ID = @srpID
Order by sc_DateOfService


GO
GRANT EXECUTE ON  [dbo].[d_SafetyCost_sp] TO [public]
GO
