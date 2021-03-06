codeunit 60100 "Customer Category PKT"
{
    // [FEATURE] Customer Category
    // [FEATURE] Customer Category UI
    SubType = Test;

    var
        Assert: codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";

    [Test]
    procedure AssignNonBlockedCustomerCategoryToCustomer()
    // [FEATURE] Customer Category
    var
        Customer: Record Customer;
        CustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0001] Assign non-blocked customer category to customer

        // [GIVEN] A non-blocked customer category
        CustomerCategoryCode := CreateNonBlockedCustomerCategory();
        // [GIVEN] A customer
        CreateCustomer(Customer);

        // [WHEN] Set customer category on customer
        SetCustomerCategoryOnCustomer(Customer, CustomerCategoryCode);

        // [THEN] Customer has customer category code field populated
        VerifyCustomerCategoryOnCustomer(Customer."No.", CustomerCategoryCode);
    end;

    [Test]
    procedure AssignBlockedCustomerCategoryToCustomer()
    // [FEATURE] Customer Category
    var
        Customer: Record Customer;
        CustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0002] Assign blocked customer category to customer

        // [GIVEN] A blocked customer category
        CustomerCategoryCode := CreateBlockedCustomerCategory();
        // [GIVEN] A customer
        CreateCustomer(Customer);

        // [WHEN] Set customer category on customer
        asserterror SetCustomerCategoryOnCustomer(Customer, CustomerCategoryCode);

        // [THEN] Blocked category error thrown
        VerifyBlockedCategoryErrorThrown();
    end;

    [Test]
    procedure AssignNonExistingCustomerCategoryToCustomer()
    // [FEATURE] Customer Category
    var
        Customer: Record Customer;
        CustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0003] Assign non-existing customer category to customer

        // [GIVEN] A non-existing customer category
        CustomerCategoryCode := 'SC #0003';
        // [GIVEN] A customer record variable
        // See local variable Customer

        // [WHEN] Set non-existing customer category on customer
        asserterror SetNonExistingCustomerCategoryOnCustomer(Customer, CustomerCategoryCode);

        // [THEN] Non existing customer category error thrown
        VerifyNonExistingCustomerCategoryErrorThrown(CustomerCategoryCode);
    end;

    [Test]
    procedure AssignDefaultCategoryToACustomer()
    // [FEATURE] Customer Category
    var
        Customer: Record Customer;
        CustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0004] Assign default category to a customer

        // [GIVEN] A non-blocked default customer category
        CustomerCategoryCode := CreateNonBlockedDefaultCustomerCategory();
        // [GIVEN] a customer with customer category not equal to default customer category
        CreateCustomerWithCustomerCategoryNotEqualToDefault(Customer);

        // [WHEN] Run AssignDefaultCategory function for one customer
        RunAssignDefaultCategoryFunctionForOneCustomer(Customer."No.");

        // [THEN] Customer has default customer category
        VerifyCustomerHasDefaultCustomerCategory(Customer."No.", CustomerCategoryCode);
    end;

    [Test]
    procedure AssignDefaultCategoryToAllCustomers()
    // [FEATURE] Customer Category
    var
        Customer: Record Customer;
        CustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0005] Assign default category to all customers

        // [GIVEN] A non-blocked default customer category
        CustomerCategoryCode := CreateNonBlockedDefaultCustomerCategory();

        // [GIVEN] Customers with customer category empty
        CreateCustomersWithCustomerCategoryEmpty();

        // [WHEN] Run AssignDefaultCategory function
        RunAssignDefaultCategoryFunction();

        // [THEN] All customers have default customer category
        VerifyAllCustomersHaveDefaultCustomerCategory(CustomerCategoryCode);
    end;

    [Test]
    [HandlerFunctions('HandleConfigTemplates')]
    procedure AssignCustomerCategoryOnCustomerCard()
    // [FEATURE] Customer Category UI
    var
        CustomerCard: TestPage "Customer Card";
        CustomerCategoryCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO #0006] Assign customer category on customer card

        // [GIVEN] A non-blocked customer category
        CustomerCategoryCode := CreateNonBlockedCustomerCategory();
        // [GIVEN] A customer card
        CreateCustomerCard(CustomerCard);

        // [WHEN] Set customer category on customer card
        CustomerNo := SetCustomerCategoryOnCustomerCard(CustomerCard, CustomerCategoryCode);

        // [THEN] Customer has customer category code field populated
        VerifyCustomerCategoryOnCustomer(CustomerNo, CustomerCategoryCode);
    end;

    [Test]
    procedure AssignDefaultCategoryToCustomerFromCustomerCard()
    // [FEATURE] Customer Category UI
    var
        Customer: Record Customer;
        CustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0007] Assign default category to customer from customer card

        // [GIVEN] A non-blocked default customer category
        CustomerCategoryCode := CreateNonBlockedDefaultCustomerCategory();
        // [GIVEN] A customer with customer category not equal to default customer category
        CreateCustomerWithCustomerCategoryNotEqualToDefault(Customer);

        // [WHEN] Select "Assign Default Category" action on customer card
        SelectAssignDefaultCategoryActionOnCustomerCard(Customer."No.");

        // [THEN] Customer has default customer category
        VerifyCustomerHasDefaultCustomerCategory(Customer."No.", CustomerCategoryCode);
    end;

    [Test]
    procedure AssignDefaultCategoryToAllCustomersFromCustomerList()
    // [FEATURE] Customer Category UI
    var
        DefaultCustomerCategoryCode: Code[20];
    begin
        // [SCENARIO #0008] Assign default category to all customers from customer list

        // [GIVEN] A non-blocked default customer category
        DefaultCustomerCategoryCode := CreateNonBlockedDefaultCustomerCategory();

        // [GIVEN] Customers with customer category empty
        CreateCustomersWithCustomerCategoryEmpty();

        // [WHEN] Select "Assign Default Category to all Customers" action on customer list
        SelectAssignDefaultCategoryToAllCustomersActionOnCustomerList();

        // [THEN] All customers have default customer category
        VerifyAllCustomersHaveDefaultCustomerCategory(DefaultCustomerCategoryCode);
    end;

    local procedure CreateBlockedCustomerCategory(): Code[20]
    var
        CustomerCategory: Record "Customer Category_PKT";
    begin
        with CustomerCategory do begin
            Get(CreateNonBlockedCustomerCategory());
            Blocked := true;
            Modify();
            exit(Code);
        end;
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
    end;

    local procedure CreateCustomerCard(var CustomerCard: TestPage "Customer Card")
    begin
        CustomerCard.OpenNew();
    end;

    local procedure CreateCustomerWithCustomerCategoryNotEqualToDefault(var Customer: Record Customer)
    begin
        // calling CreateCustomer helper function suffices as customer will have an empty Customer Category Code field
        CreateCustomer(Customer);
    end;

    local procedure CreateNonBlockedCustomerCategory(): Code[20]
    var
        CustomerCategory: Record "Customer Category_PKT";
    begin
        with CustomerCategory do begin
            Init();
            Validate(
                Code,
                LibraryUtility.GenerateRandomCode(FIELDNO(Code),
                Database::"Customer Category_PKT"));
            Validate(Description, Code);
            Insert();
            exit(Code);
        end;
    end;

    local procedure CreateNonBlockedDefaultCustomerCategory(): Code[20]
    var
        CustomerCategory: Record "Customer Category_PKT";
    begin
        with CustomerCategory do begin
            SetRange(Default, true);
            if not FindFirst() then begin
                Get(CreateNonBlockedCustomerCategory());
                Default := true;
                Modify();
            end;
            exit(Code);
        end;
    end;

    local procedure CreateCustomersWithCustomerCategoryEmpty()
    var
        Customer: Record Customer;
    begin
        Customer.DeleteAll();
        // calling CreateCustomer helper function suffices as customer will have an empty Customer Category Code field
        CreateCustomer(Customer);
        CreateCustomer(Customer);
        CreateCustomer(Customer);
        CreateCustomer(Customer);
        CreateCustomer(Customer);
        CreateCustomer(Customer);
    end;

    local procedure RunAssignDefaultCategoryFunction()
    var
        CustomerCategoryMgt: Codeunit "Customer Category Mgt_PKT";
    begin
        CustomerCategoryMgt.AssignDefaultCategory();
    end;

    local procedure RunAssignDefaultCategoryFunctionForOneCustomer(CustomerNo: Code[20])
    var
        CustomerCategoryMgt: Codeunit "Customer Category Mgt_PKT";
    begin
        CustomerCategoryMgt.AssignDefaultCategory(CustomerNo);
    end;

    local procedure SelectAssignDefaultCategoryActionOnCustomerCard(CustomerNo: Code[20])
    var
        CustomerCard: TestPage "Customer Card";
    begin
        with CustomerCard do begin
            OpenView();
            GoToKey(CustomerNo);
            "Assign default category".Invoke();
        end;
    end;

    local procedure SelectAssignDefaultCategoryToAllCustomersActionOnCustomerList()
    var
        CustomerList: TestPage "Customer List";
    begin
        with CustomerList do begin
            OpenView();
            "Assign Default Category".Invoke();
        end;
    end;

    local procedure SetCustomerCategoryOnCustomer(var Customer: Record Customer; CustomerCategoryCode: Code[20])
    begin
        with Customer do begin
            Validate("Customer Category Code_PKT", CustomerCategoryCode);
            Modify();
        end;
    end;

    local procedure SetCustomerCategoryOnCustomerCard(var CustomerCard: TestPage "Customer Card"; CustomerCategoryCode: Code[20]) CustomerNo: Code[20]
    begin
        with CustomerCard do begin
            "Customer Category PKT".SetValue(CustomerCategoryCode);
            CustomerNo := "No.".Value();
            Close();
        end;
    end;

    local procedure SetNonExistingCustomerCategoryOnCustomer(var Customer: Record Customer; CustomerCategoryCode: Code[20])
    begin
        SetCustomerCategoryOnCustomer(Customer, CustomerCategoryCode);
    end;

    local procedure VerifyAllCustomersHaveDefaultCustomerCategory(DefaultCustomerCategoryCode: Code[20])
    var
        Customer: Record Customer;
        TotalNoOfCustomers: Integer;
        NoOfCustomersWithDefaultCustomerCategoryCode: Integer;
    begin
        with Customer do begin
            TotalNoOfCustomers := Count();
            SetRange("Customer Category Code_PKT", DefaultCustomerCategoryCode);
            NoOfCustomersWithDefaultCustomerCategoryCode := Count();
            Assert.AreEqual(TotalNoOfCustomers, NoOfCustomersWithDefaultCustomerCategoryCode, 'No. of customers with Default Customer Category');
        end;
    end;

    local procedure VerifyBlockedCategoryErrorThrown()
    var
        CategoryIsBlockedTxt: Label 'This category is blocked.';
    begin
        Assert.ExpectedError(CategoryIsBlockedTxt);
    end;

    local procedure VerifyCustomerCategoryOnCustomer(CustomerNo: Code[20]; CustomerCategoryCode: Code[20])
    var
        Customer: Record Customer;
        FieldOnTableTxt: Label '%1 on %2';
    begin
        with Customer do begin
            Get(CustomerNo);
            Assert.AreEqual(
                CustomerCategoryCode,
                "Customer Category Code_PKT",
                StrSubstNo(
                    FieldOnTableTxt,
                    FieldCaption("Customer Category Code_PKT"),
                    TableCaption())
            );
        end;
    end;

    local procedure VerifyCustomerHasDefaultCustomerCategory(CustomerNo: Code[20]; DefaultCustomerCategoryCode: Code[20])
    begin
        VerifyCustomerCategoryOnCustomer(CustomerNo, DefaultCustomerCategoryCode)
    end;

    local procedure VerifyNonExistingCustomerCategoryErrorThrown(CustomerCategoryCode: Code[20])
    var
        Customer: Record Customer;
        CustomerCategory: Record "Customer Category_PKT";
        ValueCannotBeFoundInTableTxt: Label 'The field %1 of table %2 contains a value (%3) that cannot be found in the related table (%4).';
    begin
        with Customer do
            Assert.ExpectedError(
                StrSubstNo(
                    ValueCannotBeFoundInTableTxt,
                    FieldCaption("Customer Category Code_PKT"),
                    TableCaption(),
                    CustomerCategoryCode,
                    CustomerCategory.TableCaption()));
    end;

    [ModalPageHandler]
    procedure HandleConfigTemplates(var ConfigTemplates: TestPage "Config Templates")
    begin
        ConfigTemplates.OK.Invoke();
    end;
}