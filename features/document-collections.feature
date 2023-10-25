Feature: Grouping documents into a collection
  As an organisation,
  I want to present regularly published documents as collection
  So that my users can more easily find earlier publications of the same type

  Background:
    Given I am a writer in the organisation "Government Department"

  @design-system-only
  Scenario: Deleting a group
    Given a document collection "May 2012 Update" exists
    And the document collection "May 2012 Update" has a group with the heading "Temporary group"
    When I delete the group "Temporary group"
    Then I can see that the group "Temporary group" has been deleted

  @design-system-only
  Scenario: Adding a new group
    When I draft a new document collection called "May 2012 Update"
    And I add the group "Brand new group"
    Then I can see that the group "Brand new group" has been added

  @design-system-only
  Scenario: Editing a group
    Given a document collection "May 2012 Update" exists
    And the document collection "May 2012 Update" has a group with the heading "Group to be edited"
    When I edit the group "Group to be edited"'s heading to "Interesting new heading"
    Then I can see that the heading has been updated to "Interesting new heading"

  @design-system-only
  Scenario: Adding a document to a group via title
    Given a document collection "Collection" exists
    And the document collection "Collection" has a group with the heading "Group"
    And a published document "Document 1" exists
    When I select to add a new document to the collection group "By title"
    And I search by "title" for "Document 1"
    And I add "Document 1" to the document collection
    Then I should see "Document 1" in the list for the collection group "Group"

  @design-system-only
  Scenario: Adding a document to a group via URL
    Given a document collection "Collection" exists
    And the document collection "Collection" has a group with the heading "Group"
    And a GovUK Url exists "https://www.gov.uk/document-1" with title "Document 1"
    When I select to add a new document to the collection group "By URL"
    And I add URL "https://www.gov.uk/document-1" to the document collection
    Then I should see "Document 1" in the list for the collection group "Group"

  @design-system-only
  Scenario: Removing a document from a group
    Given a published publication called "Document to be removed" in a published document collection
    When I remove the publication "Document to be removed" from the group
    Then I can see that "Document to be removed" has been removed from the group

  @design-system-only
  Scenario: Reordering groups
    Given a document collection "May 2012 Update" exists
    And the following groups exist within "May 2012 Update":
      | name    |
      | Group 1 |
      | Group 2 |
    When I visit the Reorder page
    And I set the order of "May 2012 Update" groups to:
      | name    | order |
      | Group 1 | 1     |
      | Group 2 | 0     |
    Then I can see a "Group has been reordered" success flash
    And the groups should be in the following order:
      | name    |
      | Group 2 |
      | Group 1 |

  @design-system-only
  Scenario: Reordering documents within a group
    Given a document collection "Collection" exists
    And the document collection "Collection" has a group with the heading "Group"
    And a published document "Document 1" exists
    And a published document "Document 2" exists
    When I select to add a new document to the collection group "By title"
    And I search by "title" for "Document 1"
    And I add "Document 1" to the document collection
    Then I should see "Document 1" in the list for the collection group "Group"
    When I select to add a new document to the collection group "By title"
    And I search by "title" for "Document 2"
    And I add "Document 2" to the document collection
    Then I should see "Document 2" in the list for the collection group "Group"
    Then I visit the Reorder document page
    And within the "Collection" "Group" I set the order of the documents to:
      | name       | order |
      | Document 1 | 1     |
      | Document 2 | 0     |
    Then I can see a "Document has been reordered" success flash
    And the document collection group's documents should be in the following order:
      | name       |
      | Document 2 |
      | Document 1 |
