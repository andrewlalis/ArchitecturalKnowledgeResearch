# Design Decisions

This document contains the basic definitions of each type of Architectural Design Decision, as they will be used to categorize emails and issues when filtering content.

## Architectural Knowledge

A catch-all term under which any of the below definitions falls. If content is categorized as any type of design decision mentioned in this document, it is also implicitly a type of architectural knowledge.

## Structural

Decisions that lead to the creation of subsystems, layers, partitions, and components in some view of the architecture, or decisions that are related to how the elements of a system interact to provide functionality or to satisfy some non-functional requirement (quality attribute), or connectors. *Note: Old "Behavioral" tag was merged with this one.*

Examples:

> The proposed design is:
> * Assign each host T random tokens.
> * A partition is assigned to a host for each of its tokens, where the
> partition is defined by the interval between a token and the previous token on the ring.

> We're starting to see client protocol limitations impact performance, and so we'd like to evolve the protocol to remove the limitations.

## Property

Decisions that establish an enduring trait or quality of the system. Property decisions can be design rules or guidelines (when expressed positively) or design constraints (when expressed negatively).

- Specifically, these include an discussion which establishes some known property of the system.

Examples:

> As the first aspect of the discussion, we should probably state the overall goals and scoping for this effort:
> * An alternative authentication mechanism to Kerberos for user authentication
> * A broader capability for integration into enterprise identity and SSO solutions
> * Possibly the advertisement/negotiation of available authentication mechanisms
> * Backward compatibility for the existing use of Kerberos
> * No (or minimal) changes to existing Hadoop tokens (delegation, job, block access, etc)
> * Pluggable authentication mechanisms across: RPC, REST and webui enforcement points
> * Continued support for existing authorization policy/ACLs, etc
> * Keeping more fine grained authorization policies in mind - like attribute based access control



## Ban

Decisions which state that some elements will not appear in the system's design or implementation.

Examples:

> 

## Technology

Decisions involving a choice of certain technologies for a system, such as programming languages, databases, messaging systems, or frameworks.

- Most discussions about technology choices fall under this category, even if no final decision is made.

Examples:

> Should we broaden the focus to using and running Cassandra in Kubernetes in general? CEP 2 Kubernetes Operator

## Tool

Decisions that involve tools that developers use, such as online issue and project management boards, IDEs, or supplementary programs like package managers.

Examples:

> I really do not think it's worth looking at Reviewboard at reviews.apache.org again.  We have used it in the past, and it has all the downsides of gerrit and none of the upsides.  And some extra downsides of its own.

## Process

Decisions about the overarching process developers must follow when implementing the software.

Examples:

> Reviewers should be able to suggest when experimental is warranted, and conversation on dev+jira to justify when it's transitioned from experimental to stable?

> I propose that we take advantage of the dev list to perform that
> separation.  Major new features and architectural improvements should be discussed first here, then when consensus on design is achieved, moved to Jira for implementation and review.



## Additional Notes When Categorizing

- Only consider the first few pieces of content.
- When no architectural knowledge can be found in the first source item, or there is ambiguity, then continue the search.
- Tag all non-architectural-knowledge sources as `not-ak`, and include an extra `spam` tag when the content of the source is clearly machine-generated.